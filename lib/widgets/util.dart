// data_generator.dart
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/message_util.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import '../utils/salesforce_util.dart';

class Util {

  static String customEndpointForSyncMessages       = '/services/apexrest/FinPlan/api/sms/sync/*';
  static String customEndpointForApproveMessages    = '/services/apexrest/FinPlan/api/sms/approve/*';
  static String customEndpointForDeleteAllMessagesAndTransactions = '/services/apexrest/FinPlan/api/delete/*';

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

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

  static Future<List<dynamic>> getInvestmentsData() async{
    
    var investmentList = [];

    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Investment__c', 
      fieldList: ['Id', 'Name', 'FinPlan__Type__c', 'FinPlan__Investment_Code__c'], 
      whereClause: "FinPlan__Status__c = 'Active'",
      orderByClause: 'FinPlan__Type__c asc, Name asc',
    );

    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside getInvestmentsList : ${error.toString()}');
    if(debug) log.d('Data inside getInvestmentsList : ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside getInvestmentsList : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        if(detaildebug) log.d('Inside getInvestmentsList Data where data is not empty');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            investmentList.add(record);
          }
        }
      }
      catch(error){
        if(debug) log.e('Error Inside getInvestmentsList : $error');
      }
    }
    if(debug) log.d('Inside getInvestmentsList=>$investmentList');
    return investmentList; 

  }

}
