// data_generator.dart
// ignore_for_file: constant_identifier_names
import 'package:ExpenseManager/utils/salesforce_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class HomeDataGenerator {

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');
  static bool specialdebug = bool.parse(dotenv.env['specialdebug'] ?? 'false');

  // static const int TOP5 = 5;

  static const String DATE_FORMAT_IN  = 'yyyy-MM-dd'; // Format to denote yyyy-mm-dd format
  
  static Future<List<Map<String, Map<String, dynamic>>>> generateDataForHomeScreen0({ DateTime? startDate, DateTime? endDate }) async {
    
    if(debug) log.d('generateDataForHomeScreen0 : StartDate is $startDate, endDate is $endDate');
    
    List<Map<String, Map<String, dynamic>>> generateDataForHomeScreen0 = [];

    // Expected Format
    // Map<String, Map<String, dynamic>> oneYearData = {
    //   '01' : {}, '02' : {}, '03' : {}, '04' : {},
    //   '05' : {}, '06' : {}, '07' : {}, '08' : {},
    //   '09' : {}, '10' : {}, '11' : {}, '12' : {},
    // };
    Map<String, Map<String, dynamic>> oneYearData = {};
    
    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Transaction__c', 
      fieldList: ['Id', 'FinPlan__Beneficiary_Name__c','FinPlan__Transaction_Date__c', 'FinPlan__Amount__c','FinPlan__Type__c'],
      // whereClause: "FinPlan__Type__c = 'Debit'",
      // orderByClause: 'FinPlan__Amount__c desc',
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      // count : TOP5
    );

    if(debug) log.d('Error inside generateDataForHomeScreen0 : ${response['error'].toString()}');
    if(debug) log.d('Data inside generateDataForHomeScreen0 : ${response['data'].toString()}');
    
    if(response['error'] != null && response['error'].isNotEmpty){
      if(debug) log.d('Error occurred while querying inside generateDataForHomeScreen0 : ${response['error']}');
      //return null;
    }
    else if (response['data'] != null && response['data'].isNotEmpty) {
      try{
        if(detaildebug) log.d('Inside generateDataForHomeScreen0 Data where data is not empty');
        
        dynamic records = response['data']['data']; // both the objects have the primary key as `data`
        
        if(records != null && records.isNotEmpty){
          
          Map<String, dynamic> data;

          log.d('Total record count=> ${records.length}');

          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);

            log.d('Data=>${recordMap['FinPlan__Transaction_Date__c']}');

            String timeFrame = '${recordMap['FinPlan__Transaction_Date__c'].split('-')[1]} ${recordMap['FinPlan__Transaction_Date__c'].split('-')[0]}';
            log.d('timeFrame=>$timeFrame');
            // time frame expected format is 01 2024 (for Jan 2024)

            data = oneYearData[timeFrame] ?? {'Credit' : 0.0, 'Debit' : 0.0,};

            double amount = recordMap['FinPlan__Amount__c'];
            if(recordMap['FinPlan__Type__c'] == 'Credit'){
              double existingCreditData = data['Credit'] ?? 0.0;
              existingCreditData = existingCreditData + amount;
              data['Credit'] = existingCreditData;
            }
            else if(recordMap['FinPlan__Type__c'] == 'Debit'){
              double existingDebitData = data['Debit'] ?? 0.0;
              existingDebitData = existingDebitData + amount;
              data['Debit'] = existingDebitData;
            }
            else{
              log.e('the transaction type is => ${recordMap['FinPlan__Type__c']}');
            }

            oneYearData[timeFrame] = data;

            log.d('TOTAL=> $oneYearData');
          }
        }
      }
      catch(error){
        log.e('Error Inside generateDataForHomeScreen0 : $error');
      }
    }
    try{generateDataForHomeScreen0 = convert(oneYearData);}
    catch(err){
      log.e(err);
    }
    if(specialdebug) log.d('Inside generateDataForHomeScreen0=>$generateDataForHomeScreen0');
    return Future.value(generateDataForHomeScreen0); 
  }
  
  // This method converts map of <String, dynamic> to a list<dynamic> and also reverse adds them since the 
  // existing oneYearData Map data is added by ascending month - year. We need to convert them to descending
  // month - year format to show in UI
  static List<Map<String, Map<String, dynamic>>> convert(Map<String, Map<String, dynamic>> oneYearData) {
    log.d('Inside convert method 1');
    List<Map<String, Map<String, dynamic>>> data = [];
    String timeFrame;
    for(int i=1 ; i<oneYearData.keys.length; i++){
      timeFrame = oneYearData.keys.elementAt(i-1); // The format is 01 2024 i.e. mm <space> yyyy
      log.d('Time frame is=> $timeFrame');
      Map<String, dynamic> monthData = oneYearData[timeFrame] ?? {};
      data.add({
        timeFrame : monthData
      });
    }
    log.d('Reversed data is=> $data');
    return data;
  }
  
}
