// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'dart:core';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:device_info/device_info.dart';

class MessageUtil {
  
  static Logger log = Logger();

  static const int MAXM_MESSAGE_COUNT = 1000;

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
          kinds: smsKinds, // SmsQueryKind.inbox ,SmsQueryKind.sent, SmsMessageKind.draft
          address: sender, // +1234567890
          count: MAXM_MESSAGE_COUNT,
        );
      }
      
    } 
    else {
      await Permission.sms.request();
    }
    // log.d('Inbox message count : ${messages.length}');
    return sort(messages);
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

  // Method to sort the messages as per received at value, records are to be arranged by date asc
  static List<SmsMessage> sort(List<SmsMessage> msgList){
    // List<SmsMessage> sortedMsgList = [];
    // for(int i = msgList.length-1; i >= 0; i--){
    //   sortedMsgList.add(msgList[i]);
    // }
    // return sortedMsgList;

    // sorting is not required at the moment, because balance update works when messages are arranged most recent on top
    return msgList;
  }
}