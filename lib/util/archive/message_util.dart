// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'dart:core';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:device_info/device_info.dart';

class MessageUtil {
  
  static Logger log = Logger();

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
      messages = await SmsQuery().querySms(
        kinds: smsKinds, // SmsQueryKind.inbox ,SmsQueryKind.sent, SmsMessageKind.draft
        address: sender, // +254712345789
        // count: count,    // 10
      );
    } 
    else {
      await Permission.sms.request();
    }
    log.d('Inbox message count : ${messages.length}');
    return messages;
  }

  static Future<List<Map<String, dynamic>>> convert(List<SmsMessage> messages) async{
    
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceName = androidInfo.model;

    List<Map<String, dynamic>> allRecords = [];
    int count = 0;
    for (SmsMessage sms in messages) {
      Map<String, dynamic> record = {
        "attributes": {
          "type": "FinPlan__SMS_Message__c",
          "referenceId": "ref$count"
        },
        "FinPlan__Content__c": "${sms.body != null && sms.body!.length > 255 ? sms.body?.substring(0, 255) : sms.body}",
        "FinPlan__Sender__c": "${sms.sender}",
        "FinPlan__Received_At__c": sms.date.toString(),
        "FinPlan__Device__c": deviceName
      };
      allRecords.add(record);
      count++;
    }
    return allRecords;
  }
}