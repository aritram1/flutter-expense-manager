// ignore_for_file: must_be_immutable

import 'package:ExpenseManager/utils/data_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../utils/finplan_exception.dart';

class FinPlanBankAccountWidget extends StatelessWidget {
  List<Map<String, dynamic>> data = [];

  static final log = Logger();

  FinPlanBankAccountWidget({super.key, required this.data}) {
    log.d('Inside FinPlanBankAccountWidget Constructor!');
  }

  // fieldList: ['Id',
  // 'FinPlan__Account_Code__c',
  // 'Name', 'FinPlan__Last_Balance__c',
  // 'FinPlan__CC_Available_Limit__c',
  // 'FinPlan__CC_Max_Limit__c',
  // 'LastModifiedDate'],

  @override
  Widget build(BuildContext context) {
    List<Widget> allBoxes = [];
    for (Map<String, dynamic> each in data) {
      String code = each['FinPlan__Account_Code__c'];
      String name = each['Name'];
      double saLastBalance = each['FinPlan__Last_Balance__c'] ?? 0;
      double ccMaxLimit = each['FinPlan__Last_Balance__c'] ?? 0;
      double ccAvlLimit = each['FinPlan__CC_Available_Limit__c'] ?? 0;

      var sBox = Padding(
        padding: const EdgeInsets.all(4.0),
        child: () {
          if (each['FinPlan__Account_Code__c'].contains('-SA')) {
            return Card(
              color: Colors.blue.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.savings),
                title: Text(name),
                subtitle: Text(code),
                trailing: Text(NumberFormat.currency(locale: 'en_IN').format(saLastBalance))
              )
            );
          } 
          else if (each['FinPlan__Account_Code__c'].contains('-CC')) {
            return Card(
              color: Colors.pink.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.savings),
                title: Text(name),
                subtitle: Text(code),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(NumberFormat.currency(locale: 'en_IN').format(ccAvlLimit)),
                    Text(NumberFormat.currency(locale: 'en_IN').format(ccMaxLimit)),
                  ],
                )
              )
            );
          } 
          else if (each['FinPlan__Account_Code__c'].contains('-WA')) {
            return Card(
              color: Colors.green.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.savings),
                title: Text(name),
                subtitle: Text(code),
                trailing: Text(NumberFormat.currency(locale: 'en_IN').format(saLastBalance))
              )
            );
          } 
          else {
            return Card(
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.device_unknown),
                title: Text(each['N/A']),
                subtitle: const Text('N/A'),
                trailing: Text(each['N/A'])
              )
            );
          }
        }(),
      );
      allBoxes.add(sBox);
    }
    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: allBoxes,
        )
      ],
    );
  }
}
