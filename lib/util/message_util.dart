// ignore_for_file: avoid_print, constant_identifier_names

import 'dart:core';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageUtil {
  static const CONST_DEFAULT_MESSAGE_COUNT = 10;
  /////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////Get SMS Messages//////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  List<SmsMessage> messages = [];
  Future<List<SmsMessage>> getMessages(String sender, int count) async {
    var permission = await Permission.sms.status;
    //print('permission is $permission');
    if (permission.isGranted) {
      messages = await SmsQuery().querySms(
        kinds: [
          SmsQueryKind.inbox, //SmsQueryKind.sent, //SmsMessageKind.draft
        ],
        // raddress: sender, //'+254712345789'
        count: (count > 0 ? count : CONST_DEFAULT_MESSAGE_COUNT),
      );
    } 
    else {
      await Permission.sms.request();
    }
    print('Count of Messages : ${messages.length}');
    return messages;
  }
}