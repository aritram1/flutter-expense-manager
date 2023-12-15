// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SalesforceUtil79{

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
  static String customEndpointForDeleteTransactions = '/services/apexrest/FinPlan/api/transactions/delete/*';

  static String queryUrl = '/services/data/v53.0/query?q=';

  static String accessToken = '';
  static String instanceUrl = '';
  static bool isLoggedIn() => (accessToken != '');
  static Logger log = Logger();

  static Future<Map<String, String>> loginToSalesforce() async{
    Map<String, String> response = await _login();
    return response;
  }

  static Future<Map<String, String>> insertToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, String> response = {};
    response = await _insertToSalesforce(objAPIName, fieldNameValuePairs);
    return response;
  }
  
  static Future<Map<String, String>> updateToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, String> response = {};
    response = await _updateToSalesforce(objAPIName, fieldNameValuePairs);
    return response;
  }

  static Future<Map<String, String>> deleteFromSalesforce(String objAPIName, List<String> recordIds) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, String> response = {};
    response = await _deleteFromSalesforce(objAPIName, recordIds);
    return response;
  }

  static Future<Map<String, String>> queryFromSalesforce({ required String objAPIName, List<String> fieldList = const [], String whereClause = '', String orderByClause = '', int? count}) async {
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, String> response = {};
    response = await _queryFromSalesforce(objAPIName, fieldList, whereClause, orderByClause, count);
    return response;
  }

  static Future<Map<String, String>> callSalesforceAPI(String op) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, String> response = {};
    if(op == 'approve_messages'){
      response = await _callApproveMessageAPI();
    }
    if(op == 'delete_messages'){
      response = await _callDeleteMessageAPI();
    }
    if(op == 'sync'){
      response = await _callSyncMessageAPI();
    }
    if(op == 'delete_transactions'){
      response = await _callDeleteTransactionsAPI();
    }
    return response;
  }

  static Future<Map<String, String>> _callApproveMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }

  static Future<Map<String, String>> _callDeleteMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }

  static Future<Map<String, String>> _callSyncMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }
  static Future<Map<String, String>> _callDeleteTransactionsAPI() async{
    Map<String, String> response = {};
    return response;
  }

  static Future<Map<String, String>> _insertToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    return {};
  }
  static Future<Map<String, String>> _updateToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    return {};
  }
  static Future<Map<String, String>> _deleteFromSalesforce(String objAPIName, List<String> recordIds) async{
    return {};
  }
  static Future<Map<String, String>> _queryFromSalesforce(String objAPIName, List<String> fieldList, String whereClause, String orderByClause, int? count) async {
    return {};
  }
  
  static Future<Map<String, String>> _login() async{
    Map<String, String> responseMap = {};
    dynamic loginResponse;
    try{
      loginResponse = await http.post(
        Uri.parse(generateEndpointUrl('login')),
        headers: (generateHeader()),
        body: generateBody('login'),
      );
      if (loginResponse.statusCode == 200) { 
        final Map<String, dynamic> data = json.decode(loginResponse.body);
        instanceUrl = data['instance_url'];
        accessToken = data['access_token'];
      } 
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${loginResponse.body}');
      }
      // responseMap.add('data') = response.body;
    }
    catch(error){
      log.d('Error occurred while logging into Salesforce. Error is : $error');
      // responseMap.add('error') = error.toString();
    }
    return responseMap;
  }

  /////////////////////////////// generateheader method ///////////////////////////////////
  static Map<String, String> generateHeader(){
    final Map<String, String> header = {};
    header['Content-Type'] = 'application/x-www-form-urlencoded';
    if(accessToken != ''){
      header['Authorization'] = 'Bearer $accessToken';
    }
    return header;
  }

  /////////////////////////////// generate endpoint methods ///////////////////////////////////
  static String generateEndpointUrl(String opType){
    String endpointUrl = '';
    if(opType == 'login'){
      endpointUrl = '$tokenEndpoint?client_id=$clientId&client_secret=$clientSecret&username=$userName&password=$pwdWithToken&grant_type=$tokenGrantType';
    }
    if(opType == 'insert'){
      // endpointUrl = '$instanceUrl$compositeUrlForInsert$objAPIName';
    }
    else if(opType == 'sync'){
      endpointUrl = '$instanceUrl$customEndpointForSyncMessages';
    }
    else if(opType == 'update'){
      endpointUrl = '$instanceUrl$customEndpointForApproveMessages';
    }
    else if(opType == 'delete_messages'){
      endpointUrl = '$instanceUrl$customEndpointForDeleteMessages';
    }
    else if(opType == 'delete_transactions'){
      endpointUrl = '$instanceUrl$customEndpointForDeleteTransactions';
    }
    log.d('Generated URL : $endpointUrl');
    return endpointUrl;
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

  /// Generate body ///////
  static Map<String, dynamic> generateBody(String opType, {String objAPIName = '', List<Map<String, dynamic>> fieldNameValuePairs = const [], List<String> recordIds = const []}){
    Map<String, dynamic> body = {};
    if(opType == 'login'){

    }
    else if(opType == 'insert' || opType == 'sync'){
      var allRecords = [];
      int count = 0;
      for(Map<String, dynamic> eachRecord in fieldNameValuePairs){
        Map<String, dynamic> each = {};
        for(String fieldAPIName in eachRecord.keys){
          each[fieldAPIName] = eachRecord[fieldAPIName];
        }
        allRecords.add(each);
        count++;
      }
      body['records'] = allRecords;
    }
    else if(opType == 'update'){}
    else if(opType == 'delete_messages'){}
    else if(opType == 'delete_transactions'){}
    if(opType == 'approve_messages'){
      Map<String, dynamic> dataMap = {};
      dataMap['data'] = recordIds;
      body['input'] = dataMap;
    }
    log.d(body);
    return body;
  }

  



}