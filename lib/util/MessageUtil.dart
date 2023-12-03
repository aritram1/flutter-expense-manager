// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'dart:core';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class MessageUtil {
  
  static Logger log = Logger();

  ///////////////////////////////Get SMS Messages//////////////////////////////////////
  List<SmsMessage> messages = [];
  Future<List<SmsMessage>> getMessages({List<SmsQueryKind>? kinds, String? sender, int? count}) async {
    
    var permission = await Permission.sms.status;
    
    // Provide sms kind list
    List<SmsQueryKind> smsKinds = [];
    if(kinds == null){
      smsKinds.add('SmsQueryKind.inbox' as SmsQueryKind); //,SmsQueryKind.sent, SmsMessageKind.draft
    }

    if (permission.isGranted) {
      messages = await SmsQuery().querySms(
        kinds: smsKinds,
        address: sender, //'+254712345789'
        count: count,
      );
    } 
    else {
      await Permission.sms.request();
    }
    log.d('Inbox message count : ${messages.length}');
    return messages;
  }
}