// ignore: depend_on_referenced_packages
// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, constant_identifier_names, 

import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SalesforceUtil{

  static String clientId = '';
  static String clientSecret = '';
  static String userName = '';
  static String pwdWithToken = '';
  static String tokenEndpoint = '';
  static String tokenGrantType = '';
  static String compositeUrlForInsert = '';
  static String compositeUrlForUpdate = '';
  static String compositeUrlForDelete = '';
  static String queryUrl              = '';

  static String accessToken = '';
  static String instanceUrl = '';
  static Logger log = Logger();

  static bool isLoggedIn() => (accessToken != '');
  static String getAccessToken() => (accessToken);
  static String getInstanceUrl() => (instanceUrl);

  static Future<void> init() async {
    // Load environment variables from the .env file and access environment variables
    await dotenv.load(fileName: ".env");
    clientId              = dotenv.env['clientId'] ?? '';
    clientSecret          = dotenv.env['clientSecret'] ?? '';
    userName              = dotenv.env['userName'] ?? '';
    pwdWithToken          = dotenv.env['pwdWithToken'] ?? '';
    tokenEndpoint         = dotenv.env['tokenEndpoint'] ?? '';
    tokenGrantType        = dotenv.env['tokenGrantType'] ?? '';
    compositeUrlForInsert = dotenv.env['compositeUrlForInsert'] ?? '';
    compositeUrlForUpdate = dotenv.env['compositeUrlForUpdate'] ?? '';
    compositeUrlForDelete = dotenv.env['compositeUrlForDelete'] ?? '';
    queryUrl              = dotenv.env['queryUrl'] ?? '';
  }

  // Method to Login to SalesforceR
  static Future<Map<String, dynamic>> loginToSalesforce() async{
    await init();
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
        // log.d('resp in delete : $resp');

        // Process the response
        dmlToSalesforceResponse = processDMLResponse1(resp : resp, inputResponse : dmlToSalesforceResponse);
        
        eachDeleteBatch = [];
        batchCount++;
      }
    }
    else if(opType == 'insert' || opType == 'update'){
      while(fieldNameValuePairs.isNotEmpty){
        
        // Add the required value attribute and reference as applicable for successful insert/update
        for(int i=0; i<fieldNameValuePairs.length; i++){
          dynamic each = fieldNameValuePairs[i];
          if(!each.containsKey('attributes')){
            each['attributes'] = {
              "type": objAPIName,
              "referenceId": "ref$i"
            };
          }
        }

        // check the size of the list and split in a batch of `batchSize` which by default is 200
        eachBatchSize = min(fieldNameValuePairs.length, batchSize); 
        
        for(int i=0; i<eachBatchSize; i++){
          eachInsertUpdateBatch.add(fieldNameValuePairs.removeLast());
        }
        resp = await _dmlToSalesforce(opType, objAPIName, eachInsertUpdateBatch, batchCount : batchCount);
        // log.d('resp in insert update : $resp');
       
        // Process the response
        dmlToSalesforceResponse = processDMLResponse1(resp : resp, inputResponse : dmlToSalesforceResponse);
        eachInsertUpdateBatch = [];
        batchCount++;
      }
    }
    // log.d('Final value of dmlToSalesforceResponse=>' + dmlToSalesforceResponse.toString());
    return dmlToSalesforceResponse;
  }

  // Method to query Salesforce data
  static Future<Map<String, dynamic>> queryFromSalesforce({ required String objAPIName, List<String> fieldList = const [], String whereClause = '', String orderByClause = '', int? count}) async {
    if(!isLoggedIn()) await loginToSalesforce();
    Map<String, dynamic> queryFromSalesforceResponse = getGenericResponseTemplate();
    Map<String, dynamic> resp = await _queryFromSalesforce(objAPIName, fieldList, whereClause, orderByClause, count);
    log.d('Response is for records : ${resp.toString()}');
    bool done = (resp.containsKey('done') && resp['done']) ? true : false;
    if(done){
      if(resp.containsKey('data')){
        queryFromSalesforceResponse['data'] = resp;
        log.d('I am here ${queryFromSalesforceResponse['data'].toString()}');
      }
      else if(resp.containsKey('error')){
        queryFromSalesforceResponse['errors'] = resp;
      }
    }
    else{
      String nextRecordsUrl = resp['nextRecordsUrl'];
      log.d('queryFromSalesforce nextRecordsUrl =>$nextRecordsUrl');
      log.d('queryFromSalesforce url =>$instanceUrl$nextRecordsUrl');
      dynamic restRecordsResponse = await http.get(
        Uri.parse('$instanceUrl$nextRecordsUrl'),
        headers: generateHeader(),
        // body: [], //not required for query call
      );
      final Map<String, dynamic> body = json.decode(restRecordsResponse.body);
      log.d('Rest query response : ${body.toString()}');
      bool done = (resp.containsKey('done') && resp['done']) ? true : false;
      if(done){
        // Handle when record count is more than 2000
        // Collate the response for all batches
        if(body.containsKey('data') && body['data'].isNotEmpty){
          List<dynamic> existingData = queryFromSalesforceResponse['data'];
          for(dynamic each in body['data']){
            existingData.add(each);
          }
          queryFromSalesforceResponse['data'] = existingData;
        }
        if(body.containsKey('errors') && body['errors'].isNotEmpty){
          List<dynamic> existingErrors = queryFromSalesforceResponse['errors'];
          for(dynamic each in body['errors']){
            existingErrors.add(each);
          }
          queryFromSalesforceResponse['errors'] = existingErrors;
        }
      }
      else{
        // Handle when record count is more than 4000
      }
    }
    // log.d('Result from queryFromSalesforceResponse $queryFromSalesforceResponse');
    return queryFromSalesforceResponse;
  }

  // Method to connect to custom REST API
  static Future<String> callSalesforceAPI({required String endpointUrl, required httpMethod, dynamic body}) async{
    
    if(!isLoggedIn()) await loginToSalesforce();
  
    String epUrl = '$instanceUrl$endpointUrl'; 

    log.d('epUrl=>' + epUrl);   
    dynamic resp = await _callSalesforceAPI(httpMethod : httpMethod, epUrl : epUrl, body : body);
    
    log.d('resp.body=> ${resp.body}');
    
    return resp.body;
  }
  
  // private method  - gets called from `callSalesforceAPI` method
  static dynamic _callSalesforceAPI({required String httpMethod, required String epUrl, dynamic body}) async {
    dynamic resp;
    if(httpMethod == 'GET'){
      resp = await http.get(Uri.parse(epUrl), headers: generateHeader());
    }
    else if(httpMethod == 'POST'){
      resp = await http.post(Uri.parse(epUrl), headers: generateHeader(), body: jsonEncode(body));
    }
    else if(httpMethod == 'PATCH'){
      resp = await http.patch(Uri.parse(epUrl), headers: generateHeader(),body: jsonEncode(body)); 
    }
    else if(httpMethod == 'DELETE'){
      resp = await http.delete(Uri.parse(epUrl), headers: generateHeader(), body: jsonEncode(body));
    }
    log.d('epUrl $epUrl');
    return resp;
  }
  
  // private method - gets called from `login` method
  static Future<Map<String, dynamic>> _login() async{
    Map<String, dynamic> loginResponse = {};
    try{
      dynamic resp = await http.post(
        Uri.parse(generateEndpointUrl(opType : 'login')),
        headers: generateHeader(),
        // body : not required for login call
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
        // log.d('Response code other than 200 detected : ${resp.body}');
        loginResponse['error'] = body.toString();
      }
      // responseMap.add('data') = response.body;
    }
    catch(error){
      // log.d('Error occurred while logging into Salesforce. Error is : $error');
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
        // log.d('body for insert : $body');
      }
      else{
        body = await _updateToSalesforce(objAPIName, fieldNameValuePairs, batchCount);
        // log.d('body for update : $body');
      }

      log.d('I am here line 236');
      log.d('body[] : ${body.toString()}');
      // Collate the response for all batches
      if(body.containsKey('data') && body['data'].isNotEmpty){
        log.d('I am here line 227 and data is ${body['data']}');
        List<dynamic> existingData = dmlResponse['data'];
        for(dynamic each in body['data'] as List<dynamic>){
          existingData.add(each);
        }
        dmlResponse['data'] = existingData;
      }
      if(body.containsKey('errors') && body['errors'].isNotEmpty){
        List<dynamic> existingErrors = dmlResponse['errors'];
        for(dynamic each in body['errors'] as List<dynamic>){
          existingErrors.add(each);
        }
        dmlResponse['errors'] = existingErrors;
      }
      log.d('I am here line 253');
    }
    catch(error){
      // log.d('body for error scenario : $body');
      List<dynamic> catchBlockErrors = [];
      catchBlockErrors.add(error.toString());
      dmlResponse['errors'] = catchBlockErrors;
    }
    log.d('DML response for $batchCount : $dmlResponse');
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
      log.d('_insertToSalesforce StatusCode $statusCode');
      log.d('_insertToSalesforce resp.body=> ${jsonEncode(resp.body)}');
      body = json.decode(resp.body);
      log.d('ResponseBody for _insertToSalesforce => ${body.toString()}');
      if(statusCode == 201 && !body['hasErrors']){
        log.d('Inside 201 $body');
        insertResponse['data'] = body['results'];
      }
      else{ // non 201 code is returned
        // log.d('Response code other than 200/201 detected $statusCode');
        log.d('outside 201 $body');
        if(body['hasErrors']){
          insertResponse['errors'] = body['results'];
        }
      } 
    }
    catch(error){
      insertResponse['errors'] = error.toString();
    }
    log.d('Final insertResponse output : $insertResponse');
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
      // log.d('Inside _updateToSalesforce StatusCode: ${resp.statusCode} || body: $body || updateResponse: $updateResponse');
      updateResponse = processDMLResponse2(statusCode : resp.statusCode, inputBody : body, inputResponse : updateResponse);
    }
    catch(error){
      updateResponse['error'] = error.toString();
    }
    // log.d('Response from _updateToSalesforce $updateResponse');
    return updateResponse;
  }

  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _deleteFromSalesforce(String objAPIName, List<String> recordIds, int batchCount, bool hardDelete) async{
    Map<String, dynamic> deleteResponse = getGenericResponseTemplate();
    if(!isLoggedIn()) await loginToSalesforce();
    try{
      dynamic resp = await http.delete(
        Uri.parse(
          generateEndpointUrl(
            opType : 'delete', 
            objAPIName : objAPIName, 
            recordIds : recordIds, 
            batchCount : batchCount, 
            hardDelete : hardDelete)),
        headers: generateHeader(),
        // body : not required for delete call
      );
      final List<dynamic> body = json.decode(resp.body);
      // log.d('StatusCode: ${resp.statusCode} || body: $body || deleteResponse : $deleteResponse');
      deleteResponse = processDMLResponse2(statusCode : resp.statusCode, inputBody : body, inputResponse: deleteResponse);
      // log.d('After processResponse $deleteResponse');
    }
    catch(error){
      deleteResponse['error'] = error.toString();
    }
    // log.d('Response from _deleteResponse $deleteResponse');
    return deleteResponse;  
  }

  // private method - gets called from private method `queryFromSalesforce`
  static Future<Map<String, dynamic>> _queryFromSalesforce(String objAPIName, List<String> fieldList, String whereClause, String orderByClause, int? count) async {
    
    if(!isLoggedIn()) await loginToSalesforce();

    log.d('instanceUrl inside _queryFromSalesforce $instanceUrl');
    
    Map<String, dynamic> queryFromSlesforceResponse = {};
    
    try{
      dynamic resp = await http.get(
        Uri.parse(generateQueryEndpointUrl(objAPIName, fieldList, whereClause, orderByClause, count)),
        headers: generateHeader(),  
        // body: [], //not required for query call
      );
      final Map<String, dynamic> body = json.decode(resp.body);
      log.d('_queryFromSalesforce response.statusCode ${resp.statusCode}');
      log.d('_queryFromSalesforce body : ${body.toString()}');
      // log.d('_queryFromSalesforce body : $body');
      if (resp.statusCode == 200) {
        // log.d('_queryFromSalesforce resp[done] : ${body['done']}');
        // log.d('_queryFromSalesforce resp[totalSize] : ${body['totalSize']}');
        // log.d('_queryFromSalesforce resp[nextRecordsUrl] : ${body['nextRecordsUrl']}');

        queryFromSlesforceResponse['data'] = body['records'];
        queryFromSlesforceResponse['totalSize'] = body['totalSize'];
        queryFromSlesforceResponse['done'] = body['done'];
        queryFromSlesforceResponse['nextRecordsUrl'] = body['nextRecordsUrl'];
      }
      else {
        // Log an error
        log.d('Response code other than 200 detected : ${resp.body}');
        queryFromSlesforceResponse['error'] = resp.body;
      }
    }
    catch(error){
      log.d('Error occurred while querying data from Salesforce. Error is : $error');
      queryFromSlesforceResponse['error'] = error.toString();
    }
    // log.d('queryFromSlesforceResponse=> $queryFromSlesforceResponse');
    return queryFromSlesforceResponse;
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
        endpointUrl = '$instanceUrl$compositeUrlForDelete$ids';
      }
    }
    // log.d('Generated endpoint : $endpointUrl');
    return endpointUrl;
  }

  // Generic method to generate the body from the type of operation
  static Map<String, dynamic> generateBody({required String opType, String objAPIName = '', List<Map<String, dynamic>> fieldNameValuePairs = const [], List<String> recordIds = const [], int batchCount = 0}){
    Map<String, dynamic> body = {};
    if(opType == 'insert' || opType == 'update'){
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
    // // log.d(body);
    return body;
  }

  // Method specific to generate endpoint url for a query operation 
  static String generateQueryEndpointUrl(String objAPIName, List<String> fieldList, String whereClauseString, String orderByClauseString, int? count){
    String fields = fieldList.isNotEmpty ? fieldList.join(',') : 'count()';
    String whereClause = whereClauseString != '' ? 'WHERE $whereClauseString' : '' ;
    String orderByClause =  orderByClauseString != '' ? 'ORDER BY $orderByClauseString' : '';
    String limitCount = (count != null && count > 0) ? 'LIMIT $count' : '';

    String query = 'SELECT $fields FROM $objAPIName $whereClause $orderByClause $limitCount';
    log.d('Generated Query : $query');

    query = query.replaceAll(' ', '+');
    // // log.d('Encoded Query : $query');
    
    final String endpointUrl = '$instanceUrl$queryUrl$query';
    log.d('endpointUrl inside generateQueryEndpointUrl: $endpointUrl');

    return endpointUrl;
  }

  // A simple method to return a template response map which can be re-used
  static Map<String, dynamic> getGenericResponseTemplate(){
    return {'data' : [], 'errors' : []};
  }
  
  // Part 1 : a method to process the DML response
  static Map<String, dynamic> processDMLResponse1({required dynamic resp, required Map<String, dynamic> inputResponse}){
    if(resp.containsKey('data') && resp['data'].isNotEmpty){
      List<dynamic> existingData = inputResponse['data'];
      for(dynamic each in resp['data']){
        existingData.add(each);
      }
      inputResponse['data'] = existingData;
    }
    if(resp.containsKey('errors') && resp['errors'].isNotEmpty){
      List<dynamic> existingErrors = inputResponse['errors'];
      for(dynamic each in resp['errors']){
        existingErrors.add(each);
      }
      inputResponse['errors'] = existingErrors;
    }
    return inputResponse;
  }

  // Part 2 : a method to process the DML response
  static dynamic processDMLResponse2({required int statusCode, required List<dynamic> inputBody, required Map<String, dynamic> inputResponse}){
    for(dynamic rec in inputBody){
      if(statusCode == 200){
        if(rec.containsKey('success') && rec['success']){ // i.e. rec['success'] exists and it's value is true
          dynamic recordId = rec['id'];
          List<dynamic> existingData = inputResponse['data'];
          existingData.add(recordId);
          inputResponse['data'] = existingData;
        }
        else{
          dynamic errorMessage;
          List<dynamic> existingErrors = inputResponse['errors'];
          for(dynamic e in rec['errors']){
            errorMessage = '${rec['id']} : ${e['message']}';
            existingErrors.add(errorMessage);
          }
          inputResponse['errors'] = [existingErrors];
        } 
      }
      else{
        log.d('Response code other than 200 detected : $statusCode');
        inputResponse['errors'] = ['${inputBody.toString()} url: $compositeUrlForUpdate}'];
      }
    }
    return inputResponse;
  }
  
}
