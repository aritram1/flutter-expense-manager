// ignore_for_file: must_be_immutable

import 'package:ExpenseManager/utils/data_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
// import '../utils/finplan_exception.dart';

class FinPlanBankAccountWidget extends StatelessWidget {
  List<Map<String, dynamic>> data = [];

  static final log = Logger();

  FinPlanBankAccountWidget({super.key, required this.data}) {
    log.d('Inside FinPlanBankAccountWidget Constructor!');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> allBoxes = [];
    for (Map<String, dynamic> each in data) {
      
      // Create the card
      var sBox = Padding(
        padding: const EdgeInsets.all(4.0),
        child: () {
          // Savings account widget
          if (each['FinPlan__Account_Code__c'].contains('-SA')) {
            return createSAWidget(each);
          } 
          // Credit Card widget
          else if (each['FinPlan__Account_Code__c'].contains('-CC')) {
            return createCCWidget(each);
          } 
          // Wallet widget
          else if (each['FinPlan__Account_Code__c'].contains('-WA')) {
            return createWalletWidget(each);
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

    // Add to the listview and return
    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: allBoxes,
        )
      ],
    );
  }


  createSAWidget(Map<String, dynamic> each){
    // String code = each['FinPlan__Account_Code__c'];
    String name = each['Name'];
    double lastBalance = each['FinPlan__Last_Balance__c'] ?? 0;
    String lastUpdatedOn = DateFormat('dd-MM-yyyy').format(DateTime.parse(each['LastModifiedDate']));
    return Card(
      color: Colors.blue.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: const Icon(Icons.savings),
        title: Text(name),
        subtitle: Text('Last Updated on $lastUpdatedOn', style: const TextStyle(fontSize: 10)),
        trailing: Text(NumberFormat.currency(locale: 'en_IN').format(lastBalance))
      )
    );
  }


  Card createWalletWidget(Map<String, dynamic> each) {
    // String code = each['FinPlan__Account_Code__c'];
    String name = each['Name'];
    double lastBalance = each['FinPlan__Last_Balance__c'] ?? 0;
    String lastUpdatedOn = DateFormat('dd-MM-yyyy').format(DateTime.parse(each['LastModifiedDate']));
    return Card(
      color: Colors.green.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: const Icon(Icons.wallet),
        title: Text(name),
        subtitle: Text('Last Updated on $lastUpdatedOn', style: const TextStyle(fontSize: 10)),
        trailing: Text(NumberFormat.currency(locale: 'en_IN').format(lastBalance))
      )
    );
  }

  Column createCCWidget(Map<String, dynamic> each) {
    // String code = each['FinPlan__Account_Code__c'];
    String name = each['Name'];
    String lastUpdatedOn = DateFormat('dd-MM-yyyy').format(DateTime.parse(each['LastModifiedDate']));
    double ccMaxLimit = each['FinPlan__CC_Max_Limit__c'] ?? 0;
    double ccAvlLimit = each['FinPlan__CC_Available_Limit__c'] ?? 0;
    double ccSpentAmount = ccMaxLimit - ccAvlLimit;
    int ccBillingCycleDate = int.parse(each['FinPlan__CC_Billing_Cycle_Date__c'] ?? '0');
    log.d('hello!=> ${each['FinPlan__CC_Last_Bill_Paid_Date__c']}');
    
    String ccBillDueDate = '';
    if(each['FinPlan__Bill_Due_Date__c'] != null){
      ccBillDueDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(each['FinPlan__Bill_Due_Date__c']));
    }
    String ccLastBillPaidDateStr = each['FinPlan__CC_Last_Bill_Paid_Date__c'];
    double ccLastPaidAmount = each['FinPlan__CC_Last_Paid_Amount__c'] ?? 0;
    DateTime ccLastBillingDate = DateTime(DateTime.now().year, DateTime.now().month, ccBillingCycleDate);
    
    return Column(
      children: [
        Card(
          color: Colors.pink.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            leading: const Icon(Icons.credit_card),
            title: Text(name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                const Text('Last Bill Date'),
                Text(DateFormat('dd-MM-yyyy').format(ccLastBillingDate), style: const TextStyle(fontSize: 24)),
                const Text('Last Payment'),
                Text(NumberFormat.currency(locale: 'en_IN').format(ccLastPaidAmount), style: const TextStyle(fontSize: 24)),
                const Text('On'),
                Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(ccLastBillPaidDateStr)), style: const TextStyle(fontSize: 24)),
                Visibility(
                  visible: ccLastBillingDate.isBefore(DateTime.parse('${ccLastBillPaidDateStr}T00:00:00')), 
                  child: const Text('Your bill is due.', style: TextStyle(fontSize: 8, color: Colors.red)),),
                const Text('Bill Due Date'),
                Text(ccBillDueDate, style: const TextStyle(fontSize: 24)),
                Text('Last Updated on $lastUpdatedOn', style: const TextStyle(fontSize: 10)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(NumberFormat.currency(locale: 'en_IN').format(ccSpentAmount)),
                const Text('Of'),
                Text(NumberFormat.currency(locale: 'en_IN').format(ccMaxLimit))
              ],
            )
          )
        ),

        // Row(
        //   children: [
        //     Text('Last Paid amount : ${NumberFormat.currency(locale: 'en_IN').format(ccLastPaidAmount)}'),
        //     Text('Last Paid Date : $ccLastBillPaidDate'),
        //   ],
        // ),
      ],
    );
    }
}
