// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SalesforceUtil {

  static String clientId ='3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  static String clientSecret ='3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7';
  static String userName = 'aritram1@gmail.com.financeplanner';
  static String pwdWithToken =  'financeplanner123W8oC4taee0H2GzxVbAqfVB14';
  
  static String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
  static String tokenGrantType = 'password';
  static String compositeUrlForInsert = '/services/data/v53.0/composite/tree/';
  
  static String customEndpointForSyncMessages = '/services/apexrest/FinPlan/api/sms/sync/*';
  static String customEndpointForApproveMessages = '/services/apexrest/FinPlan/api/sms/approve/*';
  static String customEndpointForDeleteMessages = '/services/apexrest/FinPlan/api/sms/delete/*';
  

  static String queryUrl = '/services/data/v53.0/query?q=';

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
  static String generateQueryEndpointUrl(String objAPIName, List<String> fieldList, String whereClauseString, String orderByClauseString, int? count){
    String fields = fieldList.isNotEmpty ? fieldList.join(',') : 'count()';
    String whereClause = whereClauseString != '' ? 'WHERE $whereClauseString' : '' ;
    String orderByClause =  orderByClauseString != '' ? 'ORDER BY $orderByClauseString' : '';
    String limitCount = (count != null && count > 0) ? 'LIMIT $count' : '';

    String query = 'SELECT $fields FROM $objAPIName $whereClause $orderByClause $limitCount';
    log.d('Generated Query : $query');

    query = query.replaceAll(' ', '+');
    log.d('Encoded Query : $query');
    
    final String endpointUrl = '$instanceUrl$queryUrl$query';
    return endpointUrl;
  }

  
  static String generateInsertUpdateEndpointUrl(String objAPIName, String opType){
    String endpointUrl = '';
    if(opType == 'insert'){
      endpointUrl = '$instanceUrl$compositeUrlForInsert$objAPIName';
    }
    else if(opType == 'sync'){
      endpointUrl = '$instanceUrl$customEndpointForSyncMessages';
      log.d('Sync url is => $endpointUrl');
    }
    else if(opType == 'update'){
      endpointUrl = '$instanceUrl$customEndpointForApproveMessages';
    }
    else if(opType == 'delete'){
      endpointUrl = '$instanceUrl$customEndpointForDeleteMessages';
    }
    log.d('Generated URL : $endpointUrl');
    return endpointUrl;
  }

  


  static Map<String, dynamic> generateBody(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs){
    Map<String, dynamic> body = {};
    var allRecords = [];
    int count = 0;
    for(Map<String, dynamic> eachRecord in fieldNameValuePairs){
      Map<String, dynamic> each = {};
      // each['attributes'] = {
      //   'type': objAPIName,
      //   'referenceId': 'ref$count'
      // };
      for(String fieldAPIName in eachRecord.keys){
        each[fieldAPIName] = eachRecord[fieldAPIName];
      }
      allRecords.add(each);
      count++;
    }
    body['records'] = allRecords;
    log.d(body);
    return body;
  }

  /////////////////////////////////////insert method /////////////////////////////////////
  static Future<String> saveToSalesForce(String objAPIName, List<Map<String, dynamic>> data) async {
    
    List<Map<String, dynamic>> eachList = [];
    int counter = 0;
    String result = '';
    
    // check the size of the list and if more than 200, need to split to batch of 200 to 
    // avoid composite API limit (i.e. 200 records at a time)
    if(data.length <= 200){
      String currentResult = await SalesforceUtil._insertSFData(objAPIName, data);
      return currentResult;
    }
    else{
      for(Map<String, dynamic> each in data){
        eachList.add(each);
        counter++;
        if(counter == 200){
          String currentResult = await SalesforceUtil._insertSFData(objAPIName, eachList);
          log.d('currentresult=>$currentResult');
          result += currentResult;
          counter = 0;
          eachList = [];
        }     
      }
    }
    return result;
  }

  /////////////////////////////////////query method /////////////////////////////////////
  static Future<Map<String, String>> queryFromSalesForce({required String objAPIName, List<String> fieldList = const [], String whereClause = '', String orderByClause = '', int? count}) async {
    return await SalesforceUtil._querySFData(objAPIName, fieldList, whereClause, orderByClause, count);
  }

  static Future<Map<String, String>> _querySFData(String objAPIName, List<String> fieldList, String whereClause, String orderByClause, int? count) async {
    if(accessToken == '') await loginToSalesforce();
    dynamic response;
    Map<String, String> responseData = <String, String>{};
    try{
      response = await http.get(
        Uri.parse(generateQueryEndpointUrl(objAPIName, fieldList, whereClause, orderByClause, count)),
        headers: generateHeader(),  
        // body: jsonEncode(generateBody(objAPIName, data)),
      );
      if (response.statusCode == 200) {
        final Map<dynamic, dynamic> resp = json.decode(response.body);
        log.d('Query Operation : ${resp.toString()}');

        // Convert the 'resp' map to a JSON-formatted string
        String jsonData = json.encode(resp);

        responseData['data'] = jsonData;
      }
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${response.body}');
        responseData['error'] = response.body;
      }
      return responseData;
    }
    catch(error){
      log.d('Error occurred while querying data from Salesforce. Error is : $error');
      responseData['error'] = error.toString();
      return responseData;
    }
  }
  
  /////////////////////////////////////insert method /////////////////////////////////////
  static Future<String> _insertSFData(String objAPIName, List<Map<String, dynamic>> data) async { 
    if(accessToken == '') await loginToSalesforce();
    dynamic response;
    try{
      response = await http.post(
        Uri.parse(generateInsertUpdateEndpointUrl(objAPIName, 'sync')),//(objAPIName, 'insert')),
        headers: generateHeader(),
        body: jsonEncode(generateBody(objAPIName, data)),
      );
      log.d('response.statuscode ${response.statusCode}' );
      if(response.statusCode == 201 || response.statusCode == 200){
        final Map<dynamic, dynamic> data = json.decode(response.body);
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


  /////////////////////////////////////update method /////////////////////////////////////
  // static Future<String> updateSalesforceData(String objAPIName, List<Map<String, dynamic>> data) async { 
  static Future<String> updateSalesforceData(String objAPIName, List<String> recordIds) async { 
    if(accessToken == '') await loginToSalesforce();
    dynamic response;
    String responseString = '';
    log.d('here1');
    try{
      response = await http.post(
        Uri.parse(generateInsertUpdateEndpointUrl(objAPIName, 'update')),
        headers: generateHeader(),
        body: jsonEncode(generateUpdateBody(objAPIName, recordIds)),
      );
      log.d('here2');
      if(response.statusCode == 200){
        log.d('here3');
        // final Map<dynamic, dynamic> data = json.decode(response.body);
        responseString = json.decode(response.body);
        log.d('here4');
        log.d('Update Operation succeeded : $responseString');
      } 
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${response.body}');
      }
      return responseString;
    }
    catch(error){
      log.d('Error occurred while updating data to Salesforce. Error is : $error');
      return error.toString();
    }
  }

  // static Map<String, dynamic> generateUpdateBody(String objAPIName, List<Map<String, dynamic>> data){
  static Map<String, dynamic> generateUpdateBody(String objAPIName, List<String> recordIds){
    Map<String, dynamic> dataMap = {};
    dataMap['data'] = recordIds;
    Map<String, dynamic> response = {};
    response['input'] = dataMap;
    return response;
  }

  static Future<String> deleteSalesforceData(String objAPIName, List<String> recordIds) async { 
    if(accessToken == '') await loginToSalesforce();
    dynamic response;
    String responseString = '';
    log.d('here11');
    try{
      response = await http.post(
        Uri.parse(generateInsertUpdateEndpointUrl(objAPIName, 'delete')),
        headers: generateHeader(),
        // body: generateBody(recordIds)
      );
      log.d('here21');
      if(response.statusCode == 200){
        log.d('here31 ${response.body}');
        responseString = json.decode(response.body);
        log.d('here41 $responseString');
        log.d('Delete Operation succeeded : $responseString');
      } 
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${response.body}');
      }
      return responseString;
    }
    catch(error){
      log.d('Error occurred while Deleting data from Salesforce. Error is : $error');
      return error.toString();
    }
  }
}