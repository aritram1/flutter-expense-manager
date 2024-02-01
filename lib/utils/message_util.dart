//message_util.dart
// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'dart:core';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageUtil {

  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  static Logger log = Logger();
  
  static int maximumMessageCount = int.parse(dotenv.env['maximumMessageCount'] ?? '5');

  ///////////////////////////////Get SMS Messages//////////////////////////////////////
  static Future<List<SmsMessage>> getMessages({List<SmsQueryKind>? kinds, String? sender, int? count}) async {
    
    List<SmsMessage> messages = [];

    var permission = await Permission.sms.status;
    
    // Provide sms kind list
    List<SmsQueryKind> smsKinds = [];
    if(kinds == null){
      smsKinds = [SmsQueryKind.inbox]; //SmsQueryKind.inbox ,SmsQueryKind.sent, SmsMessageKind.draft
    }

    if (permission.isGranted) {
      if(count != null){
        messages = await SmsQuery().querySms(
          kinds: smsKinds, // SmsQueryKind.inbox ,SmsQueryKind.sent, SmsMessageKind.draft
          address: sender, // +1234567890
          count: count,    // 10
        );
      }
      else{
        messages = await SmsQuery().querySms(
          kinds: smsKinds,
          address: sender,
          // count: maximumMessageCount, // maximum message to be retrieved
        );
      }
      
    } 
    else {
      await Permission.sms.request();
    }
    log.d('Inbox all message count : ${messages.length}');

    List<SmsMessage> filteredMsgList = getOnlyImportantMessages(messages); // Filter out the non transactional messages like personal sms and OTP messages
    log.d('Inbox transactional message count : ${filteredMsgList.length}');
  
    return filteredMsgList;
  }

  // Method to convert the SMS Messages to a format that will be used for insert method later
  static Future<List<Map<String, dynamic>>> convert(List<SmsMessage> messages) async{
    
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceName = androidInfo.model;

    List<Map<String, dynamic>> allRecords = [];
    int count = 0;
    for (SmsMessage sms in messages) {
      Map<String, dynamic> record = {
        "FinPlan__Content__c": "${sms.body != null && sms.body!.length > 255 ? sms.body?.substring(0, 255) : sms.body}",
        "FinPlan__Sender__c": "${sms.sender}",
        "FinPlan__Received_At__c": sms.date.toString(),
        "FinPlan__Device__c": deviceName,
        "FinPlan__Created_From__c" : "Sync" // Explicitly set as 'Sync' so it does not fire up the trigger on SMS Object
      };
      allRecords.add(record);
      count++;
    }
    return allRecords;
  }

  // Method to filter out non transactional messages
  static List<SmsMessage> getOnlyImportantMessages(List<SmsMessage> msgList){
    List<SmsMessage> filteredMsgList = [];
    bool isOTP = false;
    bool isPersonal = false;
    bool isTransactional = false;
    for(int i = 0; i < msgList.length; i++){
      
      isOTP = msgList[i].body!.toUpperCase().contains('OTP') || msgList[i].body!.toUpperCase().contains('VERIFICATION CODE');
      isPersonal = msgList[i].sender!.toUpperCase().startsWith('+');
      isTransactional = msgList[i].body!.toUpperCase().contains('RS ') || msgList[i].body!.toUpperCase().contains('RS. ') || msgList[i].body!.toUpperCase().contains('INR ');
      
      if(!isOTP && !isPersonal && isTransactional){
        filteredMsgList.add(msgList[i]);
      }
    }

    // Clip the required number of messages from the list if the list contains sufficient items
    List<SmsMessage> listToReturn = (filteredMsgList.length <= maximumMessageCount) 
                                        ? filteredMsgList 
                                        : filteredMsgList.sublist(0, maximumMessageCount);
    return listToReturn;
  }
}