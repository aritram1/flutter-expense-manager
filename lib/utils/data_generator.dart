// data_generator.dart
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:ExpenseManager/utils/message_util.dart';
import 'package:ExpenseManager/utils/salesforce_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import 'package:device_info/device_info.dart';

class DataGenerator {

  static String customEndpointForSyncMessages       = '/services/apexrest/FinPlan/api/sms/sync/*';
  static String customEndpointForApproveMessages    = '/services/apexrest/FinPlan/api/sms/approve/*';
  static String customEndpointForDeleteAllMessagesAndTransactions = '/services/apexrest/FinPlan/api/delete/*';

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  static Future<Map<String, dynamic>> insertNewExpenseToSalesforce(String amount, String paidTo, String details, DateTime selectedDate) async {
    
    List<Map<String, dynamic>> data = [];
    
    Map<String, dynamic> each = {};
    each['FinPlan__Amount__c'] = amount;
    each['FinPlan__Beneficiary_Name__c'] = paidTo;
    each['FinPlan__Content__c'] = details;
    each['FinPlan__Transaction_Date__c'] = selectedDate.toIso8601String().split('T')[0];

    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    String deviceName = androidInfo.model;
    each['FinPlan__Device__c'] = deviceName;

    data.add(each);
    if(debug) log.d('Each entry in add new expense : $data');
    Map<String, dynamic> response =  await SalesforceUtil.dmlToSalesforce(opType: 'insert',objAPIName: 'FinPlan__Bank_Transaction__c', fieldNameValuePairs: data);
    return response;
    
  }

  static Future<Map<String, dynamic>> insertNewInvestmentToSalesforce(String amount, String paidTo, String details, DateTime selectedDate) async {
    
    List<Map<String, dynamic>> data = [];
    
    Map<String, dynamic> each = {};
    each['FinPlan__Amount__c'] = amount;
    each['FinPlan__Beneficiary_Name__c'] = paidTo;
    each['FinPlan__Content__c'] = details;
    each['FinPlan__Transaction_Date__c'] = selectedDate.toIso8601String().split('T')[0];

    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    String deviceName = androidInfo.model;
    each['FinPlan__Device__c'] = deviceName;

    data.add(each);
    if(debug) log.d('Each entry in add new investment : $data');
    Map<String, dynamic> response =  await SalesforceUtil.dmlToSalesforce(opType: 'insert',objAPIName: 'FinPlan__Investment_Transaction2__c', fieldNameValuePairs: data);
    return response;
    
  }

  static Future<Map<String, dynamic>> deleteAllMessagesAndTransactions() async {
    String response = await SalesforceUtil.callSalesforceAPI(
        endpointUrl: customEndpointForDeleteAllMessagesAndTransactions,
        httpMethod: 'POST'
    );
    return jsonDecode(response);
  }

  static Future<Map<String, dynamic>> approveSelectedMessages({required String objAPIName, required List<String> recordIds}) async {
    dynamic body = {
      'input' : {
        'data': recordIds
      }
    };
    
    String responseString = 
        await SalesforceUtil.callSalesforceAPI
          (httpMethod: 'POST', 
          endpointUrl: customEndpointForApproveMessages, 
          body : body);

    Map<String, dynamic> response = json.decode(responseString);
    return response;
  } 

  static Future<Map<String, dynamic>> syncMessages() async{
    
    // Call the specific API to delete all messages and transactions
    String mesageAndTransactionsDeleteMessage = await SalesforceUtil.callSalesforceAPI(
        httpMethod: 'POST', 
        endpointUrl: customEndpointForDeleteAllMessagesAndTransactions, 
        body: {});
    if(detaildebug) log.d('mesageAndTransactionsDeleteMessage is -> $mesageAndTransactionsDeleteMessage');
    
    // Then retrieve, convert and call the insert API for inserting messages
    List<SmsMessage> messages = await MessageUtil.getMessages();
    List<Map<String, dynamic>> processedMessages = await MessageUtil.convert(messages);
    
    Map<String, dynamic> createResponse = await SalesforceUtil.dmlToSalesforce(
        opType: 'insert',
        objAPIName : 'FinPlan__SMS_Message__c', 
        fieldNameValuePairs : processedMessages);

    if(detaildebug) log.d('syncMessages response Data => ${createResponse['data'].toString()}');
    if(detaildebug) log.d('syncMessages response Errors => ${createResponse['errors'].toString()}');

    return createResponse;
  }

  static Future<String> hardDeleteMessagesAndTransactions() async{
    
    // Call the specific API to delete all messages and transactions
    String mesageAndTransactionsDeleteMessage = await SalesforceUtil.callSalesforceAPI(
        httpMethod: 'POST', 
        endpointUrl: customEndpointForDeleteAllMessagesAndTransactions, 
        body: {});
    if(detaildebug) log.d('mesageAndTransactionsDeleteMessage is -> $mesageAndTransactionsDeleteMessage');
    
    return mesageAndTransactionsDeleteMessage;
  }

}
