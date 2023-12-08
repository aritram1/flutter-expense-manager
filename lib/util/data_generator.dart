// data_generator.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import './salesforce_util.dart';

class DataGenerator {
  static Logger log = Logger();

  static Future<List<Map<String, dynamic>>> generateTab1Data() async {
    List<Map<String, dynamic>> generatedData = [];

    try {
      Map<String, String> response = await SalesforceUtil.queryFromSalesForce(
        objAPIName: 'FinPlan__SMS_Message__c', 
        fieldList: ['Id', 'CreatedDate', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
        whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
        orderByClause: 'CreatedDate desc',
        count: 120,
      );
      String? error = response['error'];
      String? data = response['data'];

      log.d('Error: $error');
      log.d('Data: $data');
      
      if (error != null) {
        log.d('Error occurred while querying inside generateTab1Data : ${response['error']}');
      } else if (data != null) {
        Map<String, dynamic> jsonData = json.decode(data);
        if (jsonData['records'] != null) {
          log.d('response in generateTab1Data -> $jsonData');
          List<dynamic> records = jsonData['records'];
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            String id = recordMap['Id'];
            String beneficiary = recordMap['FinPlan__Beneficiary__c'];
            String amount = (recordMap['FinPlan__Formula_Amount__c'] != null) ? recordMap['FinPlan__Formula_Amount__c'].toString() : 'N/A';
            
            String date = recordMap['CreatedDate'].substring(5, 10);
            String formattedDate = '${date.split('-')[1]}/${date.split('-')[0]}';
            
            generatedData.add({
              'beneficiary': beneficiary,
              'amount': amount,
              'date': formattedDate,
              'id': id,
            });
          }
        }
      }
    } catch (error) {
      log.d('Error 2 : $error');
    }

    log.d('Inside generateTab1Data=>$generatedData');
    return generatedData;
  }

  static List<Map<String, dynamic>> generateTab2Data() {
    // Replace this with your data generation logic
    List<Map<String, dynamic>> data = List.generate(100, (index) {
      return {
        'beneficiary': 'T2 Row ${index + 1}',
        'amount': 'Data ${(index + 1) * 2}',
        'date': 'Info ${(index + 1) * 3}',
      };
    });
    return data;
  }

  static List<Map<String, dynamic>> generateTab3Data() {
    // Replace this with your data generation logic
    List<Map<String, dynamic>> data = List.generate(100, (index) {
      return {
        'beneficiary': 'T3 Row ${index + 1}',
        'amount': 'Data ${(index + 1) * 2}',
        'date': 'Info ${(index + 1) * 3}',
      };
    });
    return data;
  }

  // Add more methods or modify existing ones based on your requirements
}
