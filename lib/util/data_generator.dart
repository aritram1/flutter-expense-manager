// data_generator.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import './salesforce_util.dart';

class DataGenerator {
  static Logger log = Logger();

  static Future<List<List<String>>> generateTab1Data() async {
    List<List<String>> generatedData = [];

    Map<String, String> response = await SalesforceUtil.queryFromSalesForce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'FinPlan__Received_At_formula__c', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
      orderByClause: 'FinPlan__Received_At_formula__c desc',
      //count : 120
      );
    String? error = response['error'];
    String? data = response['data'];

    log.d('Error: $error');
    log.d('Data: $data');
    
    if(error != null){
      log.d('Error occurred while querying inside generateTab1Data : ${response['error']}');
      //return null;
    }
    else if (data != null) {
      try{
        Map<String, dynamic> jsonData = json.decode(data);
        if (jsonData['records'] != null) {
          log.d('response in generateTab1Data -> $jsonData');
          List<dynamic> records = jsonData['records'];
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            String id = recordMap['Id'];
            String beneficiary = recordMap['FinPlan__Beneficiary__c'];
            String amount = (recordMap['FinPlan__Formula_Amount__c'] != null) ? recordMap['FinPlan__Formula_Amount__c'].toString() : 'N/A' ;
            
            
            String date = recordMap['FinPlan__Received_At_formula__c'].substring(5,10);
            String formattedDate = '${date.split('-')[1]}/${date.split('-')[0]}';
            
            generatedData.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error Inside generateTab1Data : $error');
      }
    }
    log.d('Inside generateTab1Data=>$generatedData');
    return generatedData;
  } 


  static Future<List<List<String>>> generateTab2Data(DateTime selectedDate) async {
    log.d('here 1');
    log.d('Inside generate tab2 data, selected date is => $selectedDate');
    List<List<String>> generatedData = [];
    log.d('here 2');
    Map<String, String> response = await SalesforceUtil.queryFromSalesForce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'FinPlan__Received_At_formula__c', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: '',//'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
      orderByClause: 'FinPlan__Received_At_formula__c desc',
      //count : 120
      );
      log.d('here 3');
    String? error = response['error'];
    String? data = response['data'];

    log.d('Error: $error');
    log.d('Data: $data');
    log.d('here 4');
    if(error != null){
      log.d('Error occurred while querying inside generateTab2Data : ${response['error']}');
      //return null;
    }
    else if (data != null) {
      try{
        Map<String, dynamic> jsonData = json.decode(data);
        if (jsonData['records'] != null) {
          log.d('response in generateTab1Data -> $jsonData');
          List<dynamic> records = jsonData['records'];
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            String id = recordMap['Id'];
            String beneficiary = recordMap['FinPlan__Beneficiary__c'];
            String amount = (recordMap['FinPlan__Formula_Amount__c'] != null) ? recordMap['FinPlan__Formula_Amount__c'].toString() : 'N/A' ;
            log.d('here 5');
            
            String date = recordMap['FinPlan__Received_At_formula__c'].substring(5,10);
            String formattedDate = '${date.split('-')[1]}/${date.split('-')[0]}';
            log.d('here 6');
            log.d('beneficiary $beneficiary');
            log.d('amount $amount');
            log.d('formattedDate $formattedDate');
            log.d('id $id');
            
            generatedData.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error inside generateTab2Data : $error');
      }
    }
    log.d('Inside generateTab2Data=>$generatedData');
    return generatedData;
  } 

  static List<List<String>> generateTab3Data() {
    // Replace this with your data generation logic
    List<List<String>> data = List.generate(100, (index) {
      return [
        'T3 Row ${index + 1}',
        'Data ${(index + 1) * 2}',
        'Info ${(index + 1) * 3}',
      ];  
    });
    return data;
  }

  static Future<String> addExpenseToSalesforce(String amount, String paidTo, String details, DateTime selectedDate) async {
    List<Map<String, dynamic>> data = [];
    Map<String, dynamic> each = {};
    each['FinPlan__Amount_Value__c'] = amount;
    each['FinPlan__Beneficiary__c'] = paidTo;
    each['FinPlan__Content__c'] = details;
    each['FinPlan__Received_At__c'] = selectedDate.toString();
    each['FinPlan__sender__c'] = 'N/A';
    
    data.add(each);
    return await SalesforceUtil.saveToSalesForce('FinPlan__SMS_Message__c', data);
  }

  
}
