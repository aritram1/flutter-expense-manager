import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import '../message_util.dart';

class DataGeneratorLocal{

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  static Future<List<Map<String, dynamic>>> generateMockDataForHome() async {
    final List<Map<String, dynamic>> data = [];
    

    for (int i = 1; i <= 50; i++) {
      data.add({
        'Paid To': _generateRandomName(),
        'Amount': _generateRandomAmount(),
        'Date': _generateRandomDate(),
        'Id': _generateId(),
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    return data;
  }

  static String _generateId() {
    double d = (Random().nextDouble() * 1000).toDouble();
    return d.toString().replaceAll('.', 'ID').substring(0, 10);
  }

  static String _generateRandomName() {
    List<String> names = ['John Doe', 'Jane Smith', 'Bob Johnson', 'Alice Brown', 'Charlie Davis', 'Emma White'];
    return names[Random().nextInt(names.length)];
  }

  static double _generateRandomAmount() {
    // Generate a random double between 0 and 1000 with two decimal places
    double randomAmount = (Random().nextDouble() * 1000).toDouble();
    return double.parse(randomAmount.toStringAsFixed(2));
  }

  static DateTime _generateRandomDate() {
    int daysToAdd = Random().nextInt(30);
    DateTime randomDate = DateTime.now().add(Duration(days: daysToAdd));
    return randomDate;
  }

  /////////////////////////////////////////////////////////////////
  static Future<List<Map<String, dynamic>>> generateMockDataForExpenseFromDB() async {
    final List<Map<String, dynamic>> data = [];

    for (int i = 1; i <= 50; i++) {
      data.add({
        'Paid To': _generateRandomName(),
        'Amount': _generateRandomAmount(),
        'Date': _generateRandomDate(),
        'Id': _generateId(),
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    return data;
  }
  ///////////////////////////////////////////////////////////

  static Future<List<Map<String, dynamic>>> getAndEnrichAllSms() async {

    final List<Map<String, dynamic>> data = [];

    try{
      List<SmsMessage> smsList = await MessageUtil.getMessages(count : 100);
      // List<SMSMessage> localSMSList = [];
      // for(SmsMessage sms in smsList){
      //   localSMSList.add(SMSMessage(sender: sms.sender, content: sms.body, receivedAt: sms.date.toString()));
      // }
      // SMSProcessController.enrichData(localSMSList);
      
      await Future.delayed(const Duration(seconds: 1));

      // for(SMSMessage sms in localSMSList){
      //   data.add({
      //     'Paid To': sms.beneficiary,
      //     'Amount': sms.amountValue,
      //     'Date': sms.transactionDate,
      //     'Id': _generateId(),
      //   });
      // }
    }
    catch(error){
      log.e('error in message : $error');
    }

    return data;
  }

}
