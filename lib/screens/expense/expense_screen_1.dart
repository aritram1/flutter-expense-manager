import 'package:flutter/material.dart';
import '../../utils/data_generator.dart';
import '../../widgets/finplan_date_picker_panel_widget.dart';
import '../../widgets/finplan_table_widget.dart';
import 'package:logger/logger.dart';

class ExpenseScreen1 extends StatefulWidget {
  ExpenseScreen1({Key? key}) : super(key: key);

  @override
  _ExpenseScreen1State createState() => _ExpenseScreen1State();
}

class _ExpenseScreen1State extends State<ExpenseScreen1> {
  static final Logger log = Logger();

  DateTime selectedStartDate = DateTime.now().add(const Duration(days: -2));
  DateTime selectedEndDate = DateTime.now();

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from ExpenseScreen1 => $result');
  };

  late Future<List<Map<String, dynamic>>> data;

  @override
  void initState() {
    super.initState();
    data = DataGenerator.generateDataForExpenseScreen1(selectedStartDate, selectedEndDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FinPlanDatepickerPanelWidget(
          key: UniqueKey(),
          onDateRangeSelected: handleDateRangeSelection,
          startDate: selectedStartDate,
          endDate: selectedEndDate,
        ),
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
                  child: Text('Error loading data here! ${snapshot.error.toString()}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No data available in ExpenseScreen1'),
                );
              } else {
                return FinPlanTableWidget(
                  key: widget.key,
                  headerNames: const ['Paid To', 'Amount', 'Date'],
                  noRecordFoundMessage: 'Nothing to approve',
                  caller: 'ExpenseScreen1',
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

  Future<void> handleDateRangeSelection(DateTime startDate, DateTime endDate) async {
    setState(() {
      setState(() {
        selectedStartDate = startDate;
        selectedEndDate = endDate;
      });
      data = Future.value(DataGenerator.generateDataForExpenseScreen1(selectedStartDate, selectedEndDate));
    });
  }
}
