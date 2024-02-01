// data_generator.dart
// ignore_for_file: constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../utils/salesforce_util.dart';

class Util {

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  static Future<List<dynamic>> getInvestmentsData() async{
    
    var investmentList = [];

    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Investment__c', 
      fieldList: ['Id', 'Name', 'FinPlan__Type__c', 'FinPlan__Investment_Code__c'], 
      whereClause: "FinPlan__Status__c = 'Active'",
      orderByClause: 'FinPlan__Type__c asc, Name asc',
    );

    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside getInvestmentsList : ${error.toString()}');
    if(debug) log.d('Data inside getInvestmentsList : ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside getInvestmentsList : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        if(detaildebug) log.d('Inside getInvestmentsList Data where data is not empty');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            investmentList.add(record);
          }
        }
      }
      catch(error){
        if(debug) log.e('Error Inside getInvestmentsList : $error');
      }
    }
    if(debug) log.d('Inside getInvestmentsList=>$investmentList');
    return investmentList; 

  }

}
