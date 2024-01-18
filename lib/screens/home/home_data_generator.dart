// data_generator.dart
// ignore_for_file: constant_identifier_names
import 'package:ExpenseManager/utils/salesforce_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DataGenerator {

  static String customEndpointForSyncMessages       = '/services/apexrest/FinPlan/api/sms/sync/*';
  static String customEndpointForApproveMessages    = '/services/apexrest/FinPlan/api/sms/approve/*';
  static String customEndpointForDeleteAllMessagesAndTransactions = '/services/apexrest/FinPlan/api/delete/*';

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  // These two are not required now
  // static const String DATETIME_START_OF_DAY_SF_FORMAT = "yyyy-MM-dd'T'00:00:00.000'Z'"; // Format to denote start of the day i.e. midnight time in UTC
  // static const String DATETIME_END_OF_DAY_SF_FORMAT  = "yyyy-MM-dd'T'23:59:59.000'Z'";  // Format to denote till end of the day in UTC
  
  static const String DATE_FORMAT_IN  = 'yyyy-MM-dd'; // Format to denote yyyy-mm-dd format
  
  static Future<List<Map<String, dynamic>>> generateDataForHomeScreen0({required DateTime startDate, required DateTime endDate}) async {
    
    if(debug) log.d('generateDataForHomeScreen0 : StartDate is $startDate, endDate is $endDate');
    
    // Format the dates accordingly
    String formattedStartDateTime = DateFormat(DATE_FORMAT_IN).format(startDate); // startDate.toUTC() is not required since startDate is already in UTC
    String formattedEndDateTime = DateFormat(DATE_FORMAT_IN).format(endDate);       // endDate.toUTC() is not required since endDate is already in UTC
    
    // Create the date clause to use in query later
    String dateClause =  'AND FinPlan__Transaction_Date__c >= $formattedStartDateTime AND FinPlan__Transaction_Date__c <= $formattedEndDateTime';
    if(debug) log.d('StartDate is $startDate, endDate is $endDate and dateClause is=> $dateClause');

    List<Map<String, dynamic>> generateDataForHomeScreen0 = [];
    
    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'CreatedDate', 'FinPlan__Transaction_Date__c', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0 $dateClause',
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      //count : 120
      );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside generateDataForHomeScreen0 : ${error.toString()}');
    if(debug) log.d('Data inside generateDataForHomeScreen0 : ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside generateDataForHomeScreen0 : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        if(detaildebug) log.d('Inside generateDataForHomeScreen0 Data where data is not empty');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            generateDataForHomeScreen0.add({
              'Paid To': recordMap['FinPlan__Beneficiary__c'] ?? 'Default Beneficiary',
              'Amount': recordMap['FinPlan__Formula_Amount__c'] ?? 0,
              'Date': DateTime.parse(recordMap['FinPlan__Transaction_Date__c'] ?? DateTime.now().toString()),
              'Id': recordMap['Id'] ?? 'Default Id',
            });
          }
        }
      }
      catch(error){
        if(debug) log.e('Error Inside generateDataForHomeScreen0 : $error');
      }
    }
    if(detaildebug) log.d('Inside generateDataForHomeScreen0=>$generateDataForHomeScreen0');
    return generateDataForHomeScreen0; 
  }
  
}
