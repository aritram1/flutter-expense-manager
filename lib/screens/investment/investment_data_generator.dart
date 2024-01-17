// data_generator.dart
// ignore_for_file: constant_identifier_names

import 'package:ExpenseManager/utils/salesforce_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class InvestmentDataGenerator {

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

  static Future<List<Map<String, dynamic>>> generateDataForInvestmentScreen0({required DateTime startDate, required DateTime endDate}) async {
   
    if(debug) log.d('generateDataForInvestmentScreen0 : StartDate is $startDate, endDate is $endDate');
    
    // Format the dateTime to date accordingly
    String formattedStartDate = DateFormat(DATE_FORMAT_IN).format(startDate);
    String formattedEndDate = DateFormat(DATE_FORMAT_IN).format(endDate);
    
    // Create the date clause to use in query later
    String dateClause =  'FinPlan__Transaction_Date__c >= $formattedStartDate AND FinPlan__Transaction_Date__c <= $formattedEndDate';
    if(debug) log.d('StartDate is $startDate, endDate is $endDate and dateClause is=> $dateClause');

    List<Map<String, dynamic>> generatedData = [];
    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Investment_Transaction2__c', 
      fieldList: ['Id', 'FinPlan__Beneficiary_Name__c','FinPlan__Transaction_Date__c', 'FinPlan__Amount__c','FinPlan__Type__c'],
      whereClause: dateClause,
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      //count : 120
    );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(detaildebug) log.d('Error generateDataForInvestmentScreen0: ${error.toString()}');
    if(detaildebug) log.d('Data inside generateDataForInvestmentScreen0 : ${data.toString()}');

    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside generateDataForInvestmentScreen0 : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        dynamic records = data['data'];
        if (records != null && records.isNotEmpty) {
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            generatedData.add({
              'Paid To': recordMap['FinPlan__Beneficiary_Name__c'] ?? 'Default Beneficiary',
              'Amount': recordMap['FinPlan__Amount__c'] ?? 0,
              'Date': DateTime.parse(recordMap['FinPlan__Transaction_Date__c'] ?? DateTime.now().toString()),
              'Id': recordMap['Id'] ?? 'Default Id',
            });
          }
        }
      }
      catch(error){
        if(debug) log.e('Error inside generateDataForInvestmentScreen0 : $error');
      }
    }
    if(detaildebug) log.d('Inside generateDataForInvestmentScreen0=>$generatedData');
    return generatedData;
  }

}
