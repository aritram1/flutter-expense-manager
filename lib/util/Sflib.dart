// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:flutter_phone_app/util/SflibEnv.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:logger/logger.dart';


class Sflib {

  Logger log = Logger();
  
  static String authToken = '';
  static String instanceUrl = '';
  static bool isLoggedIn(){
    return (authToken != '');
  }


  ///////////////////////////////util methods///////////////////////////////////
  static Map<String, String> generateLoginHeader(){
    final Map<String, String> loginHeader = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    return loginHeader;
  }
  static Map<String, String> generateLoginBody(){
    Map<String, String> loginBody = {};
    return loginBody;
  }
  static String generateLoginURL(){
    String authUrl = '$SflibEnv._baseUrl?client_id=$SflibEnv._clientId&client_secret=$SflibEnv._clientSecret&username=$SflibEnv._userName&password=$SflibEnv._pwdWithToken&grant_type=$SflibEnv._tokenGrantType';
    return authUrl;
  }

  ///////////////////////////////login method///////////////////////////////////
  Future<void> loginToSalesforce() async {
    
    final String authUrl = generateLoginURL();
    final Map<String, String> header = generateLoginHeader();
    final Map<String, String> body = generateLoginBody();
    
    try{
      final response = await http.post(
        Uri.parse(authUrl),
        headers: (header),
        body: body,
      );
      if (response.statusCode == 200) { 
        final Map<String, dynamic> data = json.decode(response.body);
        instanceUrl = data['instance_url'];
        authToken = data['access_token'];
      } 
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${response.body}');
      }
    }
    catch(error){
      log.d('Error occurred while logging into Salesforce. Error is : $error');
    }
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