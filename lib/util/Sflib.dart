import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

class Sflib {

  static const Map<String, String> _loginCredential = {
    'tokenEndpoint' : 'https://login.salesforce.com/services/oauth2/token',
    'clientId' : '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT',
    'clientSecret' : '3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7',
    'userName' : 'aritram1@gmail.com.financeplanner',
    'tokenGrantType' : 'password',
    'pwdWithToken' : 'financeplanner123W8oC4taee0H2GzxVbAqfVB14',
  };

  static String authToken = '';
  static String instanceUrl = '';
  static bool isLoggedIn() => (authToken != '');
  static Logger log = Logger();
  
  ///////////////////////////////util methods///////////////////////////////////
  static Map<String, String> generateLoginHeader(){
    final Map<String, String> loginHeader = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    return loginHeader;
  }
  static Map<String, String> generateLoginBody(){
    return {};
  }
  static String generateLoginUrl(){
    String loginAuthUrl = '$_loginCredential.tokenEndpoint?client_id=$_loginCredential.clientId&client_secret=$_loginCredential._clientSecret&username=$_loginCredential._userName&password=$_loginCredential._pwdWithToken&grant_type=$_loginCredential._tokenGrantType';
    log.d('loginAuthUrl : $loginAuthUrl');
    return loginAuthUrl;
  }
  ///////////////////////////////login method///////////////////////////////////
  static Future<void> loginToSalesforce() async {
    try{
      final response = await http.post(
        Uri.parse(generateLoginUrl()),
        headers: (generateLoginHeader()),
        body: generateLoginBody(),
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
  //////////////////////////////////crud methods///////////////////////////////////////
  static Map<String, String> generateHeader(){
    final Map<String, String> header = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };
    return header;
  }
  static String generateEndpointUrl(String objAPIName){
    String endpointUrl = '$instanceUrl/services/data/v53.0/composite/tree/$objAPIName'; //FinPlan__SMS_Message__c;
    return endpointUrl;
  }
  static Map<String, dynamic> generateBody(String objAPIName, Map<String, dynamic> fieldNameValuePair){
    var allRecords = [];
    int count = 0;
    for(String fieldAPIName in fieldNameValuePair.keys){
      Map<String, dynamic> record = {
        "attributes": {
          "type": objAPIName,
          "referenceId": "ref$count"
        },
        fieldAPIName : fieldNameValuePair[fieldAPIName]
      };
      allRecords.add(record);
    }
    return {
      'records' : allRecords
    };
  }
  /////////////////////////////////////insert method /////////////////////////////////////
  static Future<void> insertSFData(String objAPIName, Map<String, dynamic> data) async { 
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      final response = await http.post(
        Uri.parse(generateEndpointUrl(objAPIName)),
        headers: generateHeader(),
        body: jsonEncode(generateBody(objAPIName, data)),
      );
      if(response.statusCode == 201){
        final Map<String, dynamic> data = json.decode(response.body);
        log.d('Insert Operation : ${data.toString()}');
      } 
      else {
        // Log an error
        log.d('Response code other than 201 detected : ${response.body}');
      }
    }
    catch(error){
      log.d('Error occurred while inserting data to Salesforce. Error is : $error');
    }
  }
}