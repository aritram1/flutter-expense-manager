import 'package:ExpenseManager/screens/investment/investment_data_generator.dart';
import 'package:ExpenseManager/widgets/finplan_date_picker_panel_widget.dart';
import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class InvestmentScreen0 extends StatefulWidget {
  const InvestmentScreen0({Key? key}) : super(key: key);

  @override
  InvestmentScreen0State createState() => InvestmentScreen0State();
}

class InvestmentScreen0State extends State<InvestmentScreen0> {

  // Declare the required state variables for this page
  static DateTime selectedStartDate = DateTime.now();
  static DateTime selectedEndDate = DateTime.now();
  static bool showDatePickerPanel = false;
  static late Future<List<Map<String, dynamic>>> data;
  // static final Future<List<Map<String, dynamic>>> immutableData = DataGenerator.generateDataForInvestmentScreen0(startDate : selectedStartDate, endDate : selectedEndDate);

  // Declare the final variables, they allow no modification
  static final Logger log = Logger();

  // Table on load callback defined here
  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from InvestmentScreen0 => $result');
  };

  // Init state method
  // The data is initialized here for the first time
  @override
  void initState() {
    super.initState();
    data = handleFutureDataForInvestments(); // generate the data for the first time
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The button group that shows favorite date ranges like `Today`, `Last 7 days`
        Padding(
          padding: const EdgeInsets.only(left: 16.0), 
          child: Column(
            children: [
              FinPlanDatepickerPanelWidget(
                onDateRangeSelected: handleDateRangeSelection,
                dateRanges: const ['All', 'Last 12 months', 'Last 6 months', 'Last 7 days', 'Last 30 days'],
              )
            ]
          ),
        ),
        // The table panel
        Expanded(
          child: FutureBuilder(
            future: data,
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading data in InvestmentScreen0 => ${snapshot.error.toString()}'),
                );
              } 
              else {
                return FinPlanTableWidget(
                  key: widget.key,
                  headerNames: const ['Paid To', 'Amount', 'Date'],
                  noRecordFoundMessage: 'No investments are found for this date range',
                  caller: 'InvestmentScreen0',
                  columnWidths: const [0.3, 0.2, 0.2],
                  data: snapshot.data!,
                  onLoadComplete: onLoadComplete,
                  defaultSortcolumnName: 'Date', // 2 meaning the Date column
                );
              }
            },
          ),
        ),
      ],
    );
  }
  
  // A utility method to update the state once a button is clicked
  Future<void> handleDateRangeSelection(DateTime startDate, DateTime endDate) async {
    setState(() {
      selectedStartDate = startDate;
      selectedEndDate = endDate;
      data = Future.value(InvestmentDataGenerator.generateDataForInvestmentScreen0(startDate : selectedStartDate, endDate : selectedEndDate));
    });
  }

  Future<List<Map<String, dynamic>>> handleFutureDataForInvestments() async {
    try {
      return await InvestmentDataGenerator.generateDataForInvestmentScreen0(startDate: selectedStartDate, endDate: selectedEndDate);
    } 
    catch (error, stackTrace) {
      log.e('Error in handleFutureDataForInvestments: $error');
      log.e('Stack trace: $stackTrace');
      return [];
    }
  }
  
}
