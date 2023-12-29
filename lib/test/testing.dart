// ignore_for_file: avoid_print

// import 'dart:convert';

// import '../lib2/util/salesforce_util.dart';

main() async{

  // String customEndpointForSyncMessages = '/services/apexrest/FinPlan/api/sms/sync/*';
  // String customEndpointForApproveMessages = '/services/apexrest/FinPlan/api/sms/approve/*';
  // String customEndpointForDeleteMessages = '/services/apexrest/FinPlan/api/sms/delete/*';
  // String customEndpointForDeleteTransactions = '/services/apexrest/FinPlan/api/transactions/delete/*';

  // // ------------------------------------------------------------------------------------------------ // 
  // // Login
  // dynamic loginRespone = await SalesforceUtil2.loginToSalesforce();
  // print('Login response =>${SalesforceUtil2.getAccessToken()}');
  // // ------------------------------------------------------------------------------------------------ // 
  
  // // ------------------------------------------------------------------------------------------------ // 
  // // Insert
  // List<Map<String, String>> toBeInsertedRecords = [];
  // for(int i=0;i<30;i++){
  //   Map<String, String> each = {};
  //   each['ref'] = 'Ref$i';
  //   each['name'] = 'Account-$i';
  //   each['phone'] = '123456$i';
  //   toBeInsertedRecords.add(each);
  // }
  // dynamic insertResponse = await SalesforceUtil.dmlToSalesforce(
  //     opType: 'insert', 
  //     objAPIName: 'Account', 
  //     fieldNameValuePairs : toBeInsertedRecords,
  //     batchSize: 200);
  
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
  // List<String> idList = ['0015i000014KihNAAS','0015i000014KisHAAS','0015i000014KisDAAS','0015i000014KisBAAS','0015i000014KihPAAS', '0015i000014KiaKAAS'];
  // dynamic deleteResponse = await SalesforceUtil2.dmlToSalesforce(
  //   recordIds: idList,
  //   opType: 'delete',
  //   objAPIName: 'Account'
  // );
  // print('delete response from testing.dart =>${jsonEncode(deleteResponse)}');

  // // ------------------------------------------------------------------------------------------------ // 
  // Query
  // Map<String, dynamic> queryResponse = await SalesforceUtil2.queryFromSalesforce(
  //     objAPIName: 'Account', 
  //     fieldList: ['Id', 'Website','Name', 'Phone'],
  //     whereClause: "name like 'Account%'",
  //     orderByClause: 'Name desc',
  //     count : 2050
  // );
  // print('queryResponse from testing.dart =>${jsonEncode(queryResponse)}');

  // // ------------------------------------------------------------------------------------------------ //
  // callSalesforceAPI - Approve Messages
  // Map<String, dynamic> body = {
  //   "input" : {
  //     "data": ["a0D5i00000He8YtEAJ", "a0D5i00000He8YoEAJ"]
  //   }
  // };
  // String callSalesforceAPIResponse_approveMessages = await SalesforceUtil2.callSalesforceAPI(
  //   endpointUrl: customEndpointForApproveMessages,
  //   httpMethod: 'POST',
  //   body: body
  // );
  // print('callSalesforceAPIResponse from testing.dart => $callSalesforceAPIResponse_approveMessages');

  // // ------------------------------------------------------------------------------------------------ //
  // // callSalesforceAPI - Delete Messages
  // String callSalesforceAPIResponse_deleteMessages = await SalesforceUtil2.callSalesforceAPI(
  //   endpointUrl: customEndpointForDeleteMessages,
  //   httpMethod: 'POST'
  // );
  // print('callSalesforceAPIResponse from testing.dart => $callSalesforceAPIResponse_deleteMessages');

  

}