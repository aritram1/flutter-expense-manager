import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

class Sflib {

  static String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
  static String clientId ='3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  static String clientSecret ='3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7';
  static String userName = 'aritram1@gmail.com.financeplanner';
  static String tokenGrantType = 'password';
  static String pwdWithToken =  'financeplanner123W8oC4taee0H2GzxVbAqfVB14';

  static String accessToken = '';
  static String instanceUrl = '';
  static bool isLoggedIn() => (accessToken != '');
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
    String loginAuthUrl = '$tokenEndpoint?client_id=$clientId&client_secret=$clientSecret&username=$userName&password=$pwdWithToken&grant_type=$tokenGrantType';
    log.d('loginAuthUrl : $loginAuthUrl');
    return loginAuthUrl;
  }
  ///////////////////////////////login method///////////////////////////////////
  static Future<String> loginToSalesforce() async {
    dynamic response;
    try{
      response = await http.post(
        Uri.parse(generateLoginUrl()),
        headers: (generateLoginHeader()),
        body: generateLoginBody(),
      );
      if (response.statusCode == 200) { 
        final Map<String, dynamic> data = json.decode(response.body);
        instanceUrl = data['instance_url'];
        accessToken = data['access_token'];
      } 
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${response.body}');
      }
      return response.body;
    }
    catch(error){
      log.d('Error occurred while logging into Salesforce. Error is : $error');
      return error.toString();
    }
  }
  //////////////////////////////////crud methods///////////////////////////////////////
  static Map<String, String> generateHeader(){
    final Map<String, String> header = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    return header;
  }
  static String generateEndpointUrl(String objAPIName){
    String endpointUrl = '$instanceUrl/services/data/v53.0/composite/tree/$objAPIName'; //FinPlan__SMS_Message__c;
    log.d('Generated URL : $endpointUrl');
    return endpointUrl;
  }
  static Map<String, dynamic> generateBody(String objAPIName, List<Map<String, String>> fieldNameValuePairs){
    dynamic response = {};
    var allRecords = [];
    int count = 0;
    for(dynamic eachRecord in fieldNameValuePairs){
      Map<String, dynamic> each = {};
      each['attributes'] = {
        "type": objAPIName,
        "referenceId": "ref$count"
      };
      for(String fieldAPIName in eachRecord){
        each[fieldAPIName] = eachRecord[fieldAPIName];
      }
      allRecords.add(each);
      count++;
    }
    response['records'] = allRecords;
    log.d(response);
    return response;
  }
  /////////////////////////////////////insert method /////////////////////////////////////
  static Future<String> insertSFData(String objAPIName, List<Map<String, dynamic>> data) async { 
    if(accessToken == '') await loginToSalesforce();
    dynamic response;
    try{
      response = await http.post(
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
      return response.body;
    }
    catch(error){
      log.d('Error occurred while inserting data to Salesforce. Error is : $error');
      return error.toString();
    }
  }
}