// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:ExpenseManager/screens/expense/expense_data_generator.dart';
import 'package:ExpenseManager/test/testing.dart';
import 'package:ExpenseManager/widgets/V2/finplan_tile.dart';
import 'package:ExpenseManager/widgets/V2/finplan_transaction_view.dart';
import 'package:ExpenseManager/widgets/finplan_date_picker_panel_widget.dart';
import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseScreen0 extends StatefulWidget {

  const ExpenseScreen0({super.key});

  @override
  ExpenseScreen0State createState() => ExpenseScreen0State();
}

class ExpenseScreen0State extends State<ExpenseScreen0>{

  // Declare the required state variables for this page

  static final Logger log = Logger();
  DateTime selectedStartDate = DateTime.now().add(const Duration(days: -7));
  DateTime selectedEndDate = DateTime.now();
  static bool showDatePickerPanel = false;
  static late Future<List<Map<String, dynamic>>> data;
  // static final Future<List<Map<String, dynamic>>> immutableData = DataGenerator.generateDataForExpenseScreen0(startDate : selectedStartDate, endDate : selectedEndDate);

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from ExpenseScreen0 => $result');
  };

  @override
  void initState(){
    super.initState();
    data = handleFutureDataForExpense0(selectedStartDate, selectedEndDate); // generate the data for the first time
  }

  @override
  Widget build(BuildContext context) {
    return 
      // The table panel
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0), 
            child: Column(
              children: [
                FinPlanDatepickerPanelWidget(
                  onDateRangeSelected: handleDateRangeSelection,
                ),
              ]
            ),
          ),
          Expanded(
            // padding: EdgeInsets.all(8),
            child: FutureBuilder(
              future: data,
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else if (snapshot.hasError) {
                  log.e('Error loading data => ${snapshot.error.toString()}');
                  return Center(
                    child: Text('Error loading data => ${snapshot.error.toString()}'),
                  );
                }
                else {
                  List<Widget> allTiles = [];
                  for(int i = 0; i<snapshot.data!.length; i++){
                    dynamic each = snapshot.data![i];
                    allTiles.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple.shade100, width: 1),
                            gradient: LinearGradient(colors: [Colors.purple.shade100, Colors.purple.shade200]),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: ListTile(
                            selected: true,
                            leading: getIcon(each),
                            title: Text(
                              each['Paid To'],
                              style: const TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(each['Amount']),
                                  style: const TextStyle(fontSize: 24)
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(each['Date']),
                                  // style: const TextStyle(fontSize: 24)
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              child: Icon(Icons.navigate_next),
                              onTap: (){
                                // String smsId = each['Id'];
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_)=> 
                                    Scaffold(
                                      appBar: AppBar(), 
                                      body: Center(
                                        child: SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: FinPlanTransactionView(
                                            sms: each.toString(), 
                                            onCallBack: (){}
                                          ),
                                        ),
                                      )
                                    )
                                  )
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                    allTiles.add(SizedBox( height: 4));
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: allTiles,
                    )
                  );
                  
                  // return FinPlanTableWidget(
                  //   key: widget.key,
                  //   headerNames: const ['Paid To', 'Amount', 'Date'],
                  //   noRecordFoundMessage: 'Nothing to approve',
                  //   caller: 'ExpenseScreen0',
                  //   columnWidths: const [0.3, 0.2, 0.2],
                  //   data: snapshot.data!,
                  //   onLoadComplete: onLoadComplete,
                  //   defaultSortcolumnName: 'Date',
                  // );
                }
              },
            )
          ),
        ],
      );
  }

  // A utility method to update the state once a button is clicked
  void handleDateRangeSelection(DateTime startDate, DateTime endDate) async {
    log.d('In callback startDate $startDate, endDate $endDate');
    setState(() {
      selectedStartDate = startDate;
      selectedEndDate = endDate;
      data = handleFutureDataForExpense0(startDate, endDate);
    });
  }
  
  Future<List<Map<String, dynamic>>> handleFutureDataForExpense0(DateTime startDate, DateTime endDate) async {
    try {
      return Future.value(await ExpenseDataGenerator.generateDataForExpenseScreen0(startDate: startDate, endDate: endDate));
      // return data;
    } 
    catch (error, stackTrace) {
      log.e('Error in handleFutureDataForExpense0: $error');
      log.e('Stack trace: $stackTrace');
      return Future.value([]);
    }
  }

  Icon getIcon(dynamic row){
    Icon icon;
    String type = row['BeneficiaryType'] ?? '';
    switch (type) {
      case 'Grocery':
        icon = const Icon(Icons.local_grocery_store);
        break;
      case 'Bills':
        icon = const Icon(Icons.local_activity);
        break;
      case 'Others':
        icon = const Icon(Icons.other_houses_sharp);
        break;
      default:
        icon = const Icon(Icons.other_houses_sharp);
        break;
    }
    return icon;
  }

}

// json format for data for this widget
// {
//   'Paid To': '',
//   'Amount': '',
//   'Date': '',
//   'Id': '',
//   'BeneficiaryType': '',
// }