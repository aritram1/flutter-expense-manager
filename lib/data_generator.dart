// data_generator.dart
import 'dart:convert';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'util/salesforce_util.dart';

class DataGenerator {
  static Logger log = Logger();

  static Future<List<List<String>>> generateTab1Data() async {
    List<List<String>> generatedData = [];

    Map<String, String> response = await SalesforceUtil.queryFromSalesForce(objAPIName: 'Account', fieldList: ['Id', 'Name', 'Phone'], count: 2);
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

            String id = recordMap['Id'].substring(1,4);
            String name = recordMap['Name'];
            String phone = recordMap['Phone'] ?? 'N/A';

            log.d('Dat ais=>$id $name $phone');

            // Assuming you want to display 'Id', 'Name', and 'Phone' in the table
            generatedData.add([id, name, phone]);
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




  // static Future<List<List<String>>> generateTab1Data() async {

  //   List<List<String>> data = [];

  //   List<dynamic> response = await SalesforceUtil.queryFromSalesForce(objAPIName : 'Account', fieldList: ['Id', 'name', 'phone'], count: 2);

  //   log.d('Inside generateTab1Data=>$response');




  //   // Replace this with your data generation logic
  //   // List<List<String>> data = List.generate(100, (index) {
  //   //   return [
  //   //     'T1 Row ${index + 1}',
  //   //     'Data ${(index + 1) * 2}',
  //   //     'Info ${(index + 1) * 3}',
  //   //   ];  
  //   // });
  //   return data;
  // }

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
