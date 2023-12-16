// ignore: depend_on_referenced_packages
// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SalesforceUtil2{

  static String clientId ='3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  static String clientSecret ='3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7';
  static String userName = 'aritram1@gmail.com.financeplanner';
  static String pwdWithToken =  'financeplanner123W8oC4taee0H2GzxVbAqfVB14';
  
  static String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
  static String tokenGrantType = 'password';
  static String compositeUrlForInsert = '/services/data/v53.0/composite/tree/';
  static String compositeUrlForUpdate = '/services/data/v59.0/composite/sobjects/';
  
  static String customEndpointForSyncMessages = '/services/apexrest/FinPlan/api/sms/sync/*';
  static String customEndpointForApproveMessages = '/services/apexrest/FinPlan/api/sms/approve/*';
  static String customEndpointForDeleteMessages = '/services/apexrest/FinPlan/api/sms/delete/*';
  static String customEndpointForDeleteTransactions = '/services/apexrest/FinPlan/api/transactions/delete/*';

  static String queryUrl = '/services/data/v53.0/query?q=';

  static String accessToken = '';
  static String instanceUrl = '';
  static bool isLoggedIn() => (accessToken != '');
  static Logger log = Logger();

  static Future<Map<String, dynamic>> loginToSalesforce() async{
    Map<String, String> response = await _login();
    return response;
  }

  static Future<Map<String, dynamic>> insertToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> insertResponse = getResponseTemplate();
    // check the size of the list and split in a batch of 200
    List<Map<String, dynamic>> eachBatch = [];
    int count = 0;
    int batchSize;
    String key;
    dynamic value;
    while(fieldNameValuePairs.isNotEmpty){
      batchSize = min(fieldNameValuePairs.length, 200);
      key = 'batch$count';
      for(int i=0; i<batchSize; i++){
        eachBatch.add(fieldNameValuePairs.removeLast());
      }
      Map<String, String> resp = await _insertToSalesforce(objAPIName, eachBatch);
      print('Response is==>$resp');
      if(resp.containsKey('data')){
        value = resp['data'];
        insertResponse['data'][key] = value;
      }
      else if(resp.containsKey('error')){
        value = resp['error'];
        insertResponse['error'][key] = value;
      }
      eachBatch = [];
      count++;
    }
    print('Result from insertResponse $insertResponse');
    return insertResponse;
  }

  // completed
  static Future<Map<String, String>> _insertToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    Map<String, String> _insertResponse = {};
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      dynamic resp = await http.post(
        Uri.parse(generateEndpointUrl(opType : 'insert', objAPIName : objAPIName)), // required param is opType
        headers: generateHeader(),
        body: jsonEncode(generateBody(opType : 'insert', objAPIName : objAPIName, fieldNameValuePairs : fieldNameValuePairs)),
      );
      if(resp.statusCode == 201 || resp.statusCode == 200){
        final Map<String, dynamic> body = json.decode(resp.body);
        if(!body['hasErrors']){
          int count = body['results'].length;
          _insertResponse['data'] = '$count $objAPIName records are inserted. ';
        }
        else{
          _insertResponse['error'] = 'Error occurred in _insertToSalesforce! ';
        }
      } 
      else {  
        print('Response code other than 200/201 detected ${resp.statusCode}');
        _insertResponse['error'] = json.decode(resp.body).toString();
      }
    }
    catch(error){
      _insertResponse['error'] = error.toString();
    }
    print('Response from _insertResponse $_insertResponse');
    return _insertResponse;
  }
  
  
  static Future<Map<String, dynamic>> updateToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> updateResponse = getResponseTemplate();
    // check the size of the list and split in a batch of 200
    List<Map<String, dynamic>> eachBatch = [];
    int count = 0;
    int batchSize;
    String key;
    dynamic value;
    while(fieldNameValuePairs.isNotEmpty){
      batchSize = min(fieldNameValuePairs.length, 200);
      key = 'batch$count';
      for(int i=0; i<batchSize; i++){
        eachBatch.add(fieldNameValuePairs.removeLast());
      }
      Map<String, String> resp = await _updateToSalesforce(objAPIName, eachBatch);
      print('Response is==>$resp');
      if(resp.containsKey('data')){
        value = resp['data'];
        updateResponse['data'][key] = value;
      }
      else if(resp.containsKey('error')){
        value = resp['error'];
        updateResponse['error'][key] = value;
      }
      eachBatch = [];
      count++;
    }
    print('Result from updateResponse $updateResponse');
    return updateResponse;
  }

  static Future<Map<String, dynamic>> deleteFromSalesforce(String objAPIName, List<String> recordIds, {bool hardDelete = false}) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> deleteResponse = getResponseTemplate();
    // check the size of the list and split in a batch of 200
    List<String> eachBatch = [];
    int count = 0;
    int batchSize;
    String key;
    dynamic value;
    while(recordIds.isNotEmpty){
      batchSize = min(recordIds.length, 200);
      key = 'batch$count';
      for(int i=0; i<batchSize; i++){
        eachBatch.add(recordIds.removeLast());
      }
      Map<String, String> resp = await _deleteFromSalesforce(objAPIName, eachBatch, hardDelete);
      print('_deleteFromSalesforce Response is==>$resp');
      if(resp.containsKey('data')){
        value = resp['data'];
        deleteResponse['data'][key] = value;
      }
      else if(resp.containsKey('error')){
        value = resp['error'];
        deleteResponse['error'][key] = value;
      }
      eachBatch = [];
      count++;
    }
    print('Result from deleteResponse $deleteResponse');
    return deleteResponse;
  }

  static Future<Map<String, dynamic>> queryFromSalesforce({ required String objAPIName, List<String> fieldList = const [], String whereClause = '', String orderByClause = '', int? count}) async {
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> queryResponse = getResponseTemplate();
    Map<String, String> resp = await _queryFromSalesforce(objAPIName, fieldList, whereClause, orderByClause, count);
    
    print('queryFromSalesforce Response is==>$resp');
    if(resp.containsKey('data')){
      queryResponse['data'] = resp;
    }
    else if(resp.containsKey('error')){
      queryResponse['error'] = resp;
    }
    print('Result from queryResponse $queryResponse');
    return queryResponse;
  }

  static Future<Map<String, dynamic>> callSalesforceAPI(String op) async{
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> response = {};
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

  static Future<Map<String, dynamic>> _callApproveMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }

  static Future<Map<String, dynamic>> _callDeleteMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }

  static Future<Map<String, dynamic>> _callSyncMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }
  static Future<Map<String, dynamic>> _callDeleteTransactionsAPI() async{
    Map<String, String> response = {};
    return response;
  }

  // private methods 
  
  static Future<Map<String, String>> _updateToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs) async{
    Map<String, String> _updateResponse = {};
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      dynamic resp = await http.patch(
        Uri.parse(generateEndpointUrl(opType : 'update', objAPIName : objAPIName)), // required param is opType
        headers: generateHeader(),
        body: jsonEncode(generateBody(opType : 'update', objAPIName : objAPIName, fieldNameValuePairs : fieldNameValuePairs)),
      );
      if(resp.statusCode == 201 || resp.statusCode == 200){
        final List<dynamic> body = json.decode(resp.body);
        int successCount = 0;
        String errors = '';
        for(dynamic rec in body){
          if(rec['success']){
            successCount++;
          }
          else{
            errors = errors + rec['errors'].toString();
          }
        }
        if(errors == ''){
          _updateResponse['data'] = '$successCount $objAPIName records are updated. ';
        }
        else{
          _updateResponse['error'] = errors;
        }
      } 
      else {  
        print('Response code other than 200/201 detected ${resp.statusCode}');
        _updateResponse['error'] = json.decode(resp.body).toString();
      }
    }
    catch(error){
      _updateResponse['error'] = error.toString();
    }
    print('Response from _updateResponse $_updateResponse');
    return _updateResponse;
  }
  
  
  static Future<Map<String, String>> _deleteFromSalesforce(String objAPIName, List<String> recordIds, bool hardDelete) async{
    Map<String, String> _deleteResponse = {};
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      dynamic resp = await http.delete(
        Uri.parse(generateEndpointUrl(opType : 'delete', objAPIName : objAPIName, recordIds : recordIds)), // required param is opType
        headers: generateHeader(),
        // body: [], //body not required for delete
      );
      if(resp.statusCode == 201 || resp.statusCode == 200){
        final List<dynamic> body = json.decode(resp.body);
        int successCount = 0;
        String errors = '';
        for(dynamic rec in body){
          if(rec['success']){
            successCount++;
          }
          else{
            errors = errors + rec['errors'].toString();
          }
        }
        if(errors == ''){
          _deleteResponse['data'] = '$successCount $objAPIName records are deleted. ';
        }
        else{
          _deleteResponse['error'] = errors;
        }
      }  
      else {  
        print('Response code other than 200/201 detected ${resp.statusCode}');
        // _deleteResponse['error'] = json.decode(resp.body).toString();
      }
    }
    catch(error){
      _deleteResponse['error'] = error.toString();
    }
    print('Response from _deleteResponse $_deleteResponse');
    return _deleteResponse;  
  }



  static Future<Map<String, String>> _queryFromSalesforce(String objAPIName, List<String> fieldList, String whereClause, String orderByClause, int? count) async {
    Map<String, String> _queryResponse = {};
    if(accessToken == '') await loginToSalesforce();
    Map<String, String> responseData = <String, String>{};
    try{
      dynamic resp = await http.get(
        Uri.parse(generateQueryEndpointUrl(objAPIName, fieldList, whereClause, orderByClause, count)),
        headers: generateHeader(),  
        // body: [], //not required for query call
      );
      print('response.statusCode ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(resp.body);
        print('Query Operation : $body');
        int count = body['totalSize'];
        bool done = body['done'];
        List<dynamic> records = body['records'];
        print('count : $count, done : $done , records $records');
        

        // Convert the 'resp' map to a JSON-formatted string
        // String jsonData = json.encode(resp);

        responseData['data'] = records.toString();
      }
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${resp.body}');
        responseData['error'] = resp.body;
      }
      return responseData;
    }
    catch(error){
      log.d('Error occurred while querying data from Salesforce. Error is : $error');
      responseData['error'] = error.toString();
      return responseData;
    }
  }
  
  static Future<Map<String, String>> _login() async{
    Map<String, String> responseMap = {};
    dynamic loginResponse;
    try{
      loginResponse = await http.post(
        Uri.parse(generateEndpointUrl(opType : 'login')),
        headers: generateHeader(),
        body: generateBody(opType: 'login'),
      );
      if (loginResponse.statusCode == 200) { 
        final Map<String, dynamic> data = json.decode(loginResponse.body);
        instanceUrl = data['instance_url'];
        accessToken = data['access_token'];
      } 
      else {
        // Log an error
        print('Response code other than 200 detected : ${loginResponse.body}');
      }
      // responseMap.add('data') = response.body;
    }
    catch(error){
      print('Error occurred while logging into Salesforce. Error is : $error');
      // responseMap.add('error') = error.toString();
    }
    return responseMap;
  }

  /////////////////////////////// generate type of methods ///////////////////////////////////
  static Map<String, String> generateHeader(){
    final Map<String, String> header = {};
    
    if(!isLoggedIn()){
      header['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    else{
      header['Content-Type'] = 'application/json';
      header['Authorization'] = 'Bearer $accessToken';
    }
    return header;
  }

  static String generateEndpointUrl({required String opType, String objAPIName = '', List<String> recordIds = const []}){
    String endpointUrl = '';
    if(opType == 'login'){ // completed
      endpointUrl = '$tokenEndpoint?client_id=$clientId&client_secret=$clientSecret&username=$userName&password=$pwdWithToken&grant_type=$tokenGrantType';
    }
    if(opType == 'insert'){ // completed
      endpointUrl = '$instanceUrl$compositeUrlForInsert$objAPIName';
    }
    else if(opType == 'update'){ // completed 
      endpointUrl = '$instanceUrl$compositeUrlForUpdate';
    }
    else if(opType == 'delete'){
      if(recordIds.isNotEmpty){
        String ids = recordIds.join(',');
        String compositeUrlForDelete = '/services/data/v59.0/composite/sobjects?ids=';
        endpointUrl = '$instanceUrl$compositeUrlForDelete$ids';
      }
    }
    else if(opType == 'sync'){
      endpointUrl = '$instanceUrl$customEndpointForSyncMessages';
    }
    else if(opType == 'approve_messages'){
      endpointUrl = '$instanceUrl$customEndpointForApproveMessages';
    }
    else if(opType == 'delete_messages'){
      endpointUrl = '$instanceUrl$customEndpointForDeleteMessages';
    }
    else if(opType == 'delete_transactions'){
      endpointUrl = '$instanceUrl$customEndpointForDeleteTransactions';
    }
    print('Generated endpoint : $endpointUrl');
    return endpointUrl;
  }

  static String generateQueryEndpointUrl(String objAPIName, List<String> fieldList, String whereClauseString, String orderByClauseString, int? count){
    String fields = fieldList.isNotEmpty ? fieldList.join(',') : 'count()';
    String whereClause = whereClauseString != '' ? 'WHERE $whereClauseString' : '' ;
    String orderByClause =  orderByClauseString != '' ? 'ORDER BY $orderByClauseString' : '';
    String limitCount = (count != null && count > 0) ? 'LIMIT $count' : '';

    String query = 'SELECT $fields FROM $objAPIName $whereClause $orderByClause $limitCount';
    print('Generated Query : $query');

    query = query.replaceAll(' ', '+');
    print('Encoded Query : $query');
    
    final String endpointUrl = '$instanceUrl$queryUrl$query';
    return endpointUrl;
  }

  static Map<String, dynamic> generateBody({required String opType, String objAPIName = '', List<Map<String, dynamic>> fieldNameValuePairs = const [], List<String> recordIds = const []}){
    Map<String, dynamic> body = {};
    if(opType == 'login'){
      //no body required for login
    }
    else if(opType == 'insert'){
      var allRecords = [];
      int count = 0;
      for(Map<String, dynamic> eachRecord in fieldNameValuePairs){
        Map<String, dynamic> each = {};
        each['attributes'] = {
          'type': objAPIName,
          'referenceId': 'ref$count'
        };
        for(String fieldAPIName in eachRecord.keys){
          each[fieldAPIName] = eachRecord[fieldAPIName];
        }
        allRecords.add(each);
        count++;
      }
      body['records'] = allRecords;
      // log.d('body=>' + body.toString());
    }
    else if(opType == 'update'){
      var allRecords = [];
      int count = 0;
      for(Map<String, dynamic> eachRecord in fieldNameValuePairs){
        Map<String, dynamic> each = {};
        each['attributes'] = {
          'type': objAPIName,
          'referenceId': 'ref$count'
        };
        for(String fieldAPIName in eachRecord.keys){
          each[fieldAPIName] = eachRecord[fieldAPIName];
        }
        allRecords.add(each);
        count++;
      }
      body['records'] = allRecords;
      body['allOrNone'] = false;
      print('Body is=> $body');
    }
    else if(opType == 'delete'){
      //no body required for delete
    }
    else if(opType == 'sync'){}
    else if(opType == 'delete_messages'){}
    else if(opType == 'delete_transactions'){}
    if(opType == 'approve_messages'){
      Map<String, dynamic> dataMap = {};
      dataMap['data'] = recordIds;
      body['input'] = dataMap;
    }
    // print(body);
    return body;
  }

  // may not be required
  static Map<String, dynamic> getResponseTemplate(){
      return {'data' : {},'error' : {}};
    }


  



}