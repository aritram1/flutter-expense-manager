// ignore_for_file: avoid_print, constant_identifier_names

import 'dart:convert';
import 'dart:core';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'message_util.dart'; // own lib file

class SalesforceUtil {
  static const String CONST_LOGIN_ERROR = 'Failed to login to Salesforce';
  static const String CONST_SAVE_SMS_ERROR = 'Failed to save the data to Salesforce';
  static const String CONST_INSTANCE_URL_KEYNAME = 'instance_url';
  static const String CONST_ACCESS_TOKEN_KEY_NAME = 'access_token';
  final String _baseUrl = 'https://login.salesforce.com/services/oauth2/token';
  final String _clientId = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  final String _clientSecret = '3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7'; 
  final String _userName = 'aritram1@gmail.com.financeplanner'; 
  final String _tokenGrantType = 'password'; 
  final String _pwdWithToken = 'financeplanner123W8oC4taee0H2GzxVbAqfVB14'; 
  final int CONST_BATCH_SIZE = 200;
  String instanceUrl = '';
  String token = '';
  DateTime? tokenExpiresAt;
  List<SmsMessage> allMessages = [];
  
  // final String authUrl = 'https://login.salesforce.com/services/oauth2/token?client_id=3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT&client_secret=3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7&grant_type=password&username=aritram1@gmail.com.financeplanner&password=financeplanner123W8oC4taee0H2GzxVbAqfVB14';
  
  /////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////Login To Salesforce///////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  Future<String> loginToSalesforce() async {
    String? sfResponse;
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final Map<String, String> requestBody = {};
    final String authUrl = '$_baseUrl?client_id=$_clientId&client_secret=$_clientSecret&username=$_userName&password=$_pwdWithToken&grant_type=$_tokenGrantType';
    
    try{
      final response = await http.post(
        Uri.parse(authUrl),
        headers: headers,
        body: requestBody,
      );
      if (response.statusCode == 200) { 
        final Map<String, dynamic> data = json.decode(response.body);
        instanceUrl = data[CONST_INSTANCE_URL_KEYNAME];
        token = data[CONST_ACCESS_TOKEN_KEY_NAME];
        sfResponse = data.toString();
      } else {
        sfResponse = CONST_LOGIN_ERROR;      
      }
    }
    catch(error){
      sfResponse = '{$CONST_LOGIN_ERROR : $error}';
    }
    return sfResponse;
  }

  /////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////Save To Salesforce////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  Future<String> saveToSalesForce(String sender, int count) async {
    
    String result = '';
    List<SmsMessage> eachList = [];
    int counter = 0;

    allMessages.clear();
    allMessages = await MessageUtil().getMessages(sender, count); // '' = get all messages
      
    for(SmsMessage sms in allMessages){
      eachList.add(sms);
      counter++;
      if(counter == CONST_BATCH_SIZE){
        String currentResult = await saveEachListToSalesForce('', 0, eachList);
        print('currentresult=>$currentResult');
        result += currentResult;
        counter = 0;
        eachList = [];
      }     
    }
    return result;
  }

  /////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////Save To Salesforce////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  Future<String> saveEachListToSalesForce(String sender, int count, List<SmsMessage> messages) async {
    
    String sfResponse = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceName = androidInfo.model;
    // Generate the token and retrieve the messages if not already done
    if(token == '' || instanceUrl == '') await loginToSalesforce();
    
    print('Messages are now retrieved. All messages => ${messages.length}');

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      // Add any other headers as needed
    };

    List<Map<String, dynamic>> allRecords = [];
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
      //print('record is $record');
      allRecords.add(record);
      count++;
    }
    final Map<String, dynamic> requestBody = {
      "records": allRecords,
    };
    //print('Body is ${jsonEncode(requestBody)}');
    try{
        final response = await http.post(
          Uri.parse('$instanceUrl/services/data/v53.0/composite/tree/FinPlan__SMS_Message__c'),
          headers: headers,
          body: jsonEncode(requestBody)
        );
        //print('Response received as ${response.statusCode}');
        if (response.statusCode == 201) { 
          final Map<String, dynamic> data = json.decode(response.body);
          sfResponse = data.toString();
        } else {
          sfResponse = response.body;//statusCode.toString();//CONST_SAVE_SMS_ERROR;      
        }
    }
    on Exception catch (_, e){
      sfResponse = e.toString();
    }
    return sfResponse;
  }
}