// ignore: depend_on_referenced_packages
// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, constant_identifier_names

import 'dart:convert';
import 'dart:core';
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

  static Logger log = Logger();

  static String accessToken = '';
  static String instanceUrl = '';
  static bool isLoggedIn() => (accessToken != '');
  static String getAccessToken() => (accessToken);
  static String getInstanceUrl() => (instanceUrl);

  // Method to Login to Salesforce
  static Future<Map<String, dynamic>> loginToSalesforce() async{
    Map<String, dynamic> response = await _login();
    return response;
  }

  // Method to create, update or delete records to/from Salesforce
  static Future<Map<String, dynamic>> dmlToSalesforce({String opType = '', String objAPIName = '', List<Map<String, dynamic>> fieldNameValuePairs = const [], List<String> recordIds = const [], bool hardDelete = false, int batchSize = 200}) async{
    
    if(!isLoggedIn()) await loginToSalesforce();
    
    Map<String, dynamic> dmlToSalesforceResponse = getGenericResponseTemplate();
    
    List<Map<String, dynamic>> eachInsertUpdateBatch = [];
    List<String> eachDeleteBatch = [];
    
    int eachBatchSize;
    int batchCount = 0;
    Map<String, dynamic> resp;

    if(opType == 'delete'){
      while(recordIds.isNotEmpty){
        eachBatchSize = min(recordIds.length, batchSize); // check the size of the list and split in a batch of 200
        for(int i=0; i<eachBatchSize; i++){
          eachDeleteBatch.add(recordIds.removeLast());
        }
        resp = await _deleteFromSalesforce(objAPIName, eachDeleteBatch, batchCount , hardDelete);
        // print('resp in delete : $resp');

        // Process the responses
        dmlToSalesforceResponse['data'] = dmlToSalesforceResponse['data'].add(resp['records']);
        dmlToSalesforceResponse['errors'] = dmlToSalesforceResponse['errors'].add(resp['errors']);

        eachDeleteBatch = [];
        batchCount++;
      }
    }
    else if(opType == 'insert' || opType == 'update'){
      while(fieldNameValuePairs.isNotEmpty){
        eachBatchSize = min(fieldNameValuePairs.length, batchSize); // check the size of the list and split in a batch of 200
        for(int i=0; i<eachBatchSize; i++){
          eachInsertUpdateBatch.add(fieldNameValuePairs.removeLast());
        }
        resp = await _dmlToSalesforce(opType, objAPIName, eachInsertUpdateBatch, batchCount : batchCount);
        // print('resp in insert update : $resp');
       
        // Process the response
        if(resp.containsKey('data') && resp['data'].isNotEmpty){
          List<dynamic> existingData = dmlToSalesforceResponse['data'];
          for(dynamic each in resp['data']){
            existingData.add(each);
          }
          dmlToSalesforceResponse['data'] = existingData;
        }
        if(resp.containsKey('errors') && resp['errors'].isNotEmpty){
          List<dynamic> existingErrors = dmlToSalesforceResponse['errors'];
          for(dynamic each in resp['errors']){
            existingErrors.add(each);
          }
          dmlToSalesforceResponse['errors'] = existingErrors;
        }
        eachInsertUpdateBatch = [];
        batchCount++;
      }
    }
    // print('Final value of dmlToSalesforceResponse=>' + dmlToSalesforceResponse.toString());
    return dmlToSalesforceResponse;
  }

  // private method - gets called from `login` method
  static Future<Map<String, dynamic>> _login() async{
    Map<String, dynamic> loginResponse = {};
    try{
      dynamic resp = await http.post(
        Uri.parse(generateEndpointUrl(opType : 'login')),
        headers: generateHeader(),
        body: generateBody(opType: 'login'),
      );
      log.d('I am here');
      final Map<String, dynamic> body = json.decode(resp.body);
      if (resp.statusCode == 200) {
        instanceUrl = body['instance_url'];
        accessToken = body['access_token'];
        loginResponse['data'] = body;
      } 
      else {
        // Log an error
        // print('Response code other than 200 detected : ${resp.body}');
        loginResponse['error'] = body.toString();
      }
      // responseMap.add('data') = response.body;
    }
    catch(error){
      // print('Error occurred while logging into Salesforce. Error is : $error');
      loginResponse['error'] = error.toString();
    }
    return loginResponse;
  }

  // private method  - gets called from `dmlToSalesforce` method
  static Future<Map<String, dynamic>> _dmlToSalesforce(String opType, String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs, {int batchCount = 0}) async{
    Map<String, dynamic> dmlResponse = getGenericResponseTemplate();

    Map<String, dynamic> body = {};
    try{
      if(opType == 'insert'){
        body = await _insertToSalesforce(objAPIName, fieldNameValuePairs, batchCount);
        // print('body for insert : $body');
      }
      else{
        body = await _updateToSalesforce(objAPIName, fieldNameValuePairs, batchCount);
        // print('body for update : $body');
      }

      // Collate the response for all batches
      if(body.containsKey('data') && body['data'].isNotEmpty){
        List<dynamic> existingData = dmlResponse['data'];
        for(dynamic each in body['data']){
          existingData.add(each);
        }
        dmlResponse['data'] = existingData;
      }
      if(body.containsKey('errors') && body['errors'].isNotEmpty){
        List<dynamic> existingErrors = dmlResponse['errors'];
        for(dynamic each in body['errors']){
          existingErrors.add(each);
        }
        dmlResponse['errors'] = existingErrors;
      }
    }
    catch(error){
      // print('body for error scenario : $body');
      List<dynamic> catchBlockErrors = [];
      catchBlockErrors.add(error.toString());
      dmlResponse['errors'] = catchBlockErrors;
    }
    // print('DML response for $batchCount : $dmlResponse');
    return dmlResponse;
  }

  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _insertToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs, int batchCount) async{
    Map<String, dynamic> insertResponse = getGenericResponseTemplate(); 
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> body = {};
    dynamic resp;
    try{
      resp = await http.post(
        Uri.parse(generateEndpointUrl(opType : 'insert', objAPIName : objAPIName)), // both are required params
        headers: generateHeader(),
        body: jsonEncode(generateBody(opType : 'insert', objAPIName : objAPIName, fieldNameValuePairs : fieldNameValuePairs, batchCount : batchCount)),
      );
      int statusCode = resp.statusCode;
      body = json.decode(resp.body);
      // print('ResponseBody => ${body.toString()}');
      if(statusCode == 201 && !body['hasErrors']){
        // print('Inside 201 $body');
        insertResponse['data'] = body['results'];
      }
      else{ // non 201 code is returned
        // print('Response code other than 200/201 detected $statusCode');
        // print('outside 201 $body');
        if(body['hasErrors']){
          insertResponse['errors'] = body['results'];
        }
      } 
    }
    catch(error){
      insertResponse['errors'] = error.toString();
    }
    // print('Final insertResponse output : $insertResponse');
    return insertResponse;
  }

  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _updateToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs, int batchCount) async{
    Map<String, dynamic> updateResponse = getGenericResponseTemplate();
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      dynamic resp = await http.patch(
        Uri.parse(generateEndpointUrl(opType : 'update', objAPIName : objAPIName)), // required param is opType
        headers: generateHeader(),
        body: jsonEncode(generateBody(opType : 'update', objAPIName : objAPIName, fieldNameValuePairs : fieldNameValuePairs, batchCount : batchCount)),
      );
      final List<dynamic> body = json.decode(resp.body);
      print('body within _updateToSalesforce $body');
      for(dynamic rec in body){
        if(resp.statusCode == 200){
          if(rec.containsKey('success') && rec['success']){ // i.e. rec['success'] exists and it's value is true
            dynamic recordId = rec['id'];
            List<dynamic> existingData = updateResponse['data'];
            existingData.add(recordId);
            updateResponse['data'] = existingData;
          }
          else{
            dynamic errorMessage;
            List<dynamic> existingErrors = updateResponse['errors'];
            for(dynamic e in rec['errors']){
              errorMessage = '${rec['id']} : ${e['message']}';
              existingErrors.add(errorMessage);
            }
            updateResponse['errors'] = existingErrors;
          } 
        }
        else{
          print('Response code other than 200 detected ${resp.statusCode}');
          updateResponse['errors'] = ['${body.toString()} url: $compositeUrlForUpdate}'];
        }
      }
    }
    catch(error){
      updateResponse['error'] = error.toString();
    }
    // print('Response from _updateResponse $updateResponse');
    return updateResponse;
  }
  
  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _deleteFromSalesforce(String objAPIName, List<String> recordIds, int batchCount, bool hardDelete) async{
    Map<String, dynamic> deleteResponse = getGenericResponseTemplate();
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      dynamic resp = await http.delete(
        Uri.parse(generateEndpointUrl(opType : 'delete', objAPIName : objAPIName, recordIds : recordIds, batchCount : batchCount, hardDelete : hardDelete)), // required param is opType
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
          deleteResponse['data'] = '$successCount $objAPIName records are deleted. ';
        }
        else{
          deleteResponse['error'] = errors;
        }
      }  
      else {  
        // print('Response code other than 200/201 detected ${resp.statusCode}');
        // _deleteResponse['error'] = json.decode(resp.body).toString();
      }
    }
    catch(error){
      deleteResponse['error'] = error.toString();
    }
    // print('Response from _deleteResponse $deleteResponse');
    return deleteResponse;  
  }

  // TBC
  static Future<Map<String, dynamic>> queryFromSalesforce({ required String objAPIName, List<String> fieldList = const [], String whereClause = '', String orderByClause = '', int? count}) async {
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> queryResponse = getGenericResponseTemplate();
    Map<String, dynamic> resp = await _queryFromSalesforce(objAPIName, fieldList, whereClause, orderByClause, count);
    
    if(resp.containsKey('data')){
      queryResponse['data'] = resp;
    }
    else if(resp.containsKey('error')){
      queryResponse['errors'] = resp;
    }
    // print('Result from queryResponse $queryResponse');
    return queryResponse;
  }

  // TBC
  static Future<Map<String, dynamic>> _queryFromSalesforce(String objAPIName, List<String> fieldList, String whereClause, String orderByClause, int? count) async {
    
    if(!isLoggedIn()) await loginToSalesforce();
    
    Map<String, dynamic> queryResponse = {};
    
    Map<String, String> responseData = <String, String>{};
    try{
      dynamic resp = await http.get(
        Uri.parse(generateQueryEndpointUrl(objAPIName, fieldList, whereClause, orderByClause, count)),
        headers: generateHeader(),  
        // body: [], //not required for query call
      );
      // print('response.statusCode ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(resp.body);
        // int count = body['totalSize'];
        // bool done = body['done'];
        // List<dynamic> records = body['records'];
        // print('count : ${body['totalSize']}, done : ${body['done']} , records retrieved : ${body['records']}');
        responseData['data'] = body['records'].toString();
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
  
  // Generic method to generate header for login and other operations
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

  // Generic method to generate the endpoint URL for the type of operation
  static String generateEndpointUrl({required String opType, String objAPIName = '', List<String> recordIds = const [], int batchCount = 0, bool hardDelete = false}){
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
    // // print('Generated endpoint : $endpointUrl');
    return endpointUrl;
  }

  // Generic method to generate the body from the type of operation
  static Map<String, dynamic> generateBody({required String opType, String objAPIName = '', List<Map<String, dynamic>> fieldNameValuePairs = const [], List<String> recordIds = const [], int batchCount = 0}){
    Map<String, dynamic> body = {};
    if(opType == 'login'){
      // no body element is required for login
    }
    else if(opType == 'insert' || opType == 'update'){
      var allRecords = [];
      // int count = batchCount * MAXM_BATCH_SIZE;
      for(Map<String, dynamic> eachRecord in fieldNameValuePairs){
        Map<String, dynamic> each = {};
        each['attributes'] = {
          'type': objAPIName,
          'referenceId': eachRecord['ref'] //'ref$count'
        };
        for(String fieldAPIName in eachRecord.keys){
          if(fieldAPIName != 'ref'){
            each[fieldAPIName] = eachRecord[fieldAPIName];
          }
        }
        allRecords.add(each);
        // count++;
      }
      body['records'] = allRecords;
      if(opType == 'update'){
        body['allOrNone'] = 'false';
      }// log.d('body=>' + body.toString());
    }
    else if(opType == 'delete'){
      //no body element is required for delete
    }
    else if(opType == 'sync'){}
    else if(opType == 'delete_messages'){}
    else if(opType == 'delete_transactions'){}
    if(opType == 'approve_messages'){
      Map<String, dynamic> dataMap = {};
      dataMap['data'] = recordIds;
      body['input'] = dataMap;
    }
    // // print(body);
    return body;
  }

  // Method specific to generate endpoint url for a query operation 
  static String generateQueryEndpointUrl(String objAPIName, List<String> fieldList, String whereClauseString, String orderByClauseString, int? count){
    String fields = fieldList.isNotEmpty ? fieldList.join(',') : 'count()';
    String whereClause = whereClauseString != '' ? 'WHERE $whereClauseString' : '' ;
    String orderByClause =  orderByClauseString != '' ? 'ORDER BY $orderByClauseString' : '';
    String limitCount = (count != null && count > 0) ? 'LIMIT $count' : '';

    String query = 'SELECT $fields FROM $objAPIName $whereClause $orderByClause $limitCount';
    // print('Generated Query : $query');

    query = query.replaceAll(' ', '+');
    // // print('Encoded Query : $query');
    
    final String endpointUrl = '$instanceUrl$queryUrl$query';
    // // print('endpointUrl : $endpointUrl');

    return endpointUrl;
  }

  // A simple method to return a template response map which can be used later
  static Map<String, dynamic> getGenericResponseTemplate(){
    return {'data' : [], 'errors' : []};
  }
  
  // TBC
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

  // TBC
  static Future<Map<String, dynamic>> _callApproveMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }

  // TBC
  static Future<Map<String, dynamic>> _callDeleteMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }

  // TBC
  static Future<Map<String, dynamic>> _callSyncMessageAPI() async{
    Map<String, String> response = {};
    return response;
  }
  
  // TBC
  static Future<Map<String, dynamic>> _callDeleteTransactionsAPI() async{
    Map<String, String> response = {};
    return response;
  }

}
