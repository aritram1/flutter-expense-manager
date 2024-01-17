// data_generator.dart
// ignore_for_file: constant_identifier_names

import 'package:ExpenseManager/utils/salesforce_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ExpenseDataGenerator {

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
  
  static Future<List<Map<String, dynamic>>> generateDataForExpenseScreen0({required DateTime startDate, required DateTime endDate}) async {
    
    if(debug) log.d('generateDataForExpenseScreen0 : StartDate is $startDate, endDate is $endDate');
    
    // Format the dates accordingly
    String formattedStartDateTime = DateFormat(DATE_FORMAT_IN).format(startDate); // startDate.toUTC() is not required since startDate is already in UTC
    String formattedEndDateTime = DateFormat(DATE_FORMAT_IN).format(endDate);       // endDate.toUTC() is not required since endDate is already in UTC
    
    // Create the date clause to use in query later
    String dateClause =  'AND FinPlan__Transaction_Date__c >= $formattedStartDateTime AND FinPlan__Transaction_Date__c <= $formattedEndDateTime';
    log.d('StartDate is $startDate, endDate is $endDate and dateClause is=> $dateClause');

    List<Map<String, dynamic>> generatedData = [];
    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'CreatedDate', 'FinPlan__Received_At_formula__c', 'FinPlan__Transaction_Date__c', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0 $dateClause',
      orderByClause: 'FinPlan__Received_At_formula__c desc',
      //count : 120
      );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside generateTab1Data : ${error.toString()}');
    if(debug) log.d('Data inside generateTab1Data : ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside generateTab1Data : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        if(detaildebug) log.d('Inside generateTab1 Data where data is not empty');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            generatedData.add({
              'Paid To': recordMap['FinPlan__Beneficiary__c'] ?? 'Default Beneficiary',
              'Amount': recordMap['FinPlan__Formula_Amount__c'] ?? 0,
              'Date': DateTime.parse(recordMap['FinPlan__Transaction_Date__c'] ?? DateTime.now().toString()),
              'Id': recordMap['Id'] ?? 'Default Id',
            });
          }
        }
      }
      catch(error){
        if(debug) log.e('Error Inside generateTab1Data : $error');
      }
    }
    if(detaildebug) log.d('Inside generateTab1Data=>$generatedData');
    return generatedData; 
  }
  
  static Future<List<Map<String, dynamic>>> generateDataForExpenseScreen1({required DateTime startDate, required DateTime endDate}) async {
   
    if(debug) log.d('generateDataForExpenseScreen0 : StartDate is $startDate, endDate is $endDate');
    
    // Format the dateTime to date accordingly
    String formattedStartDate = DateFormat(DATE_FORMAT_IN).format(startDate);
    String formattedEndDate = DateFormat(DATE_FORMAT_IN).format(endDate);
    
    // Create the date clause to use in query later
    String dateClause =  'FinPlan__Transaction_Date__c >= $formattedStartDate AND FinPlan__Transaction_Date__c <= $formattedEndDate';
    log.d('StartDate is $startDate, endDate is $endDate and dateClause is=> $dateClause');

    List<Map<String, dynamic>> generatedData = [];
    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Transaction__c', 
      fieldList: ['Id', 'FinPlan__Beneficiary_Name__c','FinPlan__Transaction_Date__c', 'FinPlan__Amount__c','FinPlan__Type__c'],
      whereClause: dateClause,
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      //count : 120
    );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(detaildebug) log.d('Error: ${error.toString()}');
    if(detaildebug) log.d('Data inside : ${data.toString()}');

    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside generateTab2Data : ${response['error']}');
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
        if(debug) log.e('Error inside generateTab2Data : $error');
      }
    }
    if(detaildebug) log.d('Inside generateTab2Data=>$generatedData');
    return generatedData;
  } 
 
  static Future<List<Map<String, dynamic>>> generateDataForExpenseScreen2() async {
    List<Map<String, dynamic>> generatedDataTab3 = [];

    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Account__c',
      fieldList: ['Id', 'FinPlan__Account_Code__c', 'Name', 'FinPlan__Last_Balance__c', 'FinPlan__CC_Available_Limit__c', 'FinPlan__CC_Max_Limit__c', 'LastModifiedDate'], 
      // whereClause: 'FinPlan__Last_Balance__c > 0',
      orderByClause: 'LastModifiedDate desc',
      //count : 120
      );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside generateTab3Data : ${error.toString()}');
    if(debug) log.d('Datainside generateTab3Data: ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside generateTab3Data : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        dynamic records = data['data'];
        if(detaildebug) log.d('Inside generateTab3Data Records=> $records');
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            
            String accountCode = recordMap['FinPlan__Account_Code__c'] ?? 'N/Av';  
            double balance = accountCode.contains('-CC') 
              ? recordMap['FinPlan__CC_Available_Limit__c'] ?? 0
              : recordMap['FinPlan__Last_Balance__c'] ?? 0
            ;
            DateTime lastmodifiedDate = DateTime.parse(recordMap['LastModifiedDate'] ?? DateTime.now().toString()); // example 2023-12-12T19:56:13.000+0000
            String id = recordMap['Id'] ?? 'Default Id';          
            
            generatedDataTab3.add({
              'Name': accountCode,
              'Balance': balance,
              'Last Updated': lastmodifiedDate,
              'Id': id ,
            });
          }
        }
      }
      catch(error){
        if(debug) log.e('Error Inside generateTab3Data : $error');
      }
    }
    if(debug) log.d('Inside generateTab3Data=>$generatedDataTab3');
    return generatedDataTab3;
  }

}
