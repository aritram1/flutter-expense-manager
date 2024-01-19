import 'package:ExpenseManager/screens/expense/expense_data_generator.dart';
import 'package:ExpenseManager/widgets/finplan_date_picker_panel_widget.dart';
import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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
                  return FinPlanTableWidget(
                    key: widget.key,
                    headerNames: const ['Paid To', 'Amount', 'Date'],
                    noRecordFoundMessage: 'Nothing to approve',
                    caller: 'ExpenseScreen0',
                    columnWidths: const [0.3, 0.2, 0.2],
                    data: snapshot.data!,
                    onLoadComplete: onLoadComplete,
                    defaultSortcolumnName: 'Date',
                  );
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

}