// data_generator.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import 'util/salesforce_util.dart';

class DataGenerator {
  static Logger log = Logger();

  static Future<List<List<String>>> generateTab1Data() async {
    List<List<String>> generatedData = [];

    Map<String, String> response = await SalesforceUtil.queryFromSalesForce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'CreatedDate', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
      orderByClause: 'CreatedDate desc',
      count : 120
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
            
            
            String date = recordMap['CreatedDate'].substring(5,10);
            String formattedDate = '${date.split('-')[1]}/${date.split('-')[0]}';
            
            generatedData.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error 2 : $error');
      }
    }
    log.d('Inside generateTab1Data=>$generatedData');
    return generatedData;
  }


  static List<List<String>> generateTab2Data() {
    // Replace this with your data generation logic
    List<List<String>> data = List.generate(100, (index) {
      return [
        'T2 Row ${index + 1}',
        'Data ${(index + 1) * 2}',
        'Info ${(index + 1) * 3}',
      ];  
    });
    return data;
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

  
}
