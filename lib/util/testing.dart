// ignore_for_file: avoid_print

import 'dart:convert';

import './salesforce_util2.dart';
// import './data_generator2.dart';

main() async{

  // // ------------------------------------------------------------------------------------------------ // 
  // // Login
  // dynamic loginRespone = await SalesforceUtil2.loginToSalesforce();
  // print('Login response =>${SalesforceUtil2.getAccessToken()}');
  // // ------------------------------------------------------------------------------------------------ // 
  
  // // ------------------------------------------------------------------------------------------------ // 
  // // Insert
  // List<Map<String, String>> toBeInsertedRecords = [];
  // for(int i=0;i<10;i++){
  //   Map<String, String> each = {};
  //   each['ref'] = 'Ref$i';
  //   each['name'] = 'Account-$i';
  //   each['phone'] = '123456$i';

  //   if(i == 0 || i == 3) each['name'] = '';
  //   toBeInsertedRecords.add(each);
  // }
  // dynamic insertResponse = await SalesforceUtil2.dmlToSalesforce(
  //     opType: 'insert', 
  //     objAPIName: 'Account', 
  //     fieldNameValuePairs : toBeInsertedRecords,
  //     batchSize: 3);
  
  // print('Insert response from testing.dart =>${jsonEncode(insertResponse)}');

  // // ------------------------------------------------------------------------------------------------ // 
  // // update
  // List<Map<String, String>> toBeUpdatedRecords = [];
  // List<String> allIds = ['0015i000014KisIAAS','0015i000014KisHAAS','0015i000014KisDAAS','0015i000014KisBAAS','0015i000014KihPAAS', '0015i000014KiaKAAS'];
  // for(int i=0;i<6;i++){
  //   Map<String, String> each = {};
  //   each['ref'] = 'Ref$i';
  //   each['id'] = allIds[i];
  //   each['name'] = 'Name is changed $i';
  //   each['phone'] = 'phoneischanged$i';
  //   each['fax'] = 'faxischanged$i';
    
  //   if(i == 0 || i == 3) each['name'] = '';
  //   toBeUpdatedRecords.add(each);
  // }

  // dynamic updateResponse = await SalesforceUtil2.dmlToSalesforce(
  //     opType: 'update', 
  //     objAPIName: 'Account', 
  //     fieldNameValuePairs : toBeUpdatedRecords,
  //     batchSize: 200);
  
  // print('update response from testing.dart =>${jsonEncode(updateResponse)}');

  // // ------------------------------------------------------------------------------------------------ // 
  // delete
  List<String> idList = ['0015i000014KihNAAS','0015i000014KisHAAS','0015i000014KisDAAS','0015i000014KisBAAS','0015i000014KihPAAS', '0015i000014KiaKAAS'];
  dynamic deleteResponse = await SalesforceUtil2.dmlToSalesforce(
    recordIds: idList,
    opType: 'delete',
    objAPIName: 'Account'
  );
  print('deleteResponse =>${jsonEncode(deleteResponse)}');

  // // ------------------------------------------------------------------------------------------------ // 
  // // Query
  // String whereClause = "name like 'Account%'";
  // Map<String, dynamic> queryResponse = await SalesforceUtil2.queryFromSalesforce(
  //     objAPIName: 'Account', 
  //     fieldList: ['Id', 'Website','Name', 'Phone'],
  //     whereClause: whereClause,
  //     orderByClause: 'Name desc',
  //     count : 2
  // );
  // print('queryResponse =>$queryResponse');
}