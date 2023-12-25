// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widget/date_picker_panel.dart';
import '../widget/table_widget.dart';
import '../widget/add_new_expense.dart';
import '../util/data_generator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TabWidget extends StatefulWidget {
  final int tabIndex;
  final String title;

  const TabWidget({Key? key, required this.tabIndex, required this.title}) : super(key: key);

  @override
  _TabWidgetState createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  List<List<String>> tableData = [];
  final Logger log = Logger();
  DateTime selectedStartDate = DateTime.now().add(const Duration(days: -1)); // by default show data for today and yesterday
  DateTime selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<List<List<String>>> fetchData() async {
    switch (widget.tabIndex) {
      case 0:
        return await DataGenerator.generateTab1Data();
      case 1:
        return await DataGenerator.generateTab2Data(selectedStartDate, selectedEndDate);
      case 2:
        return DataGenerator.generateTab3Data();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      floatingActionButton: () {
        switch (widget.tabIndex) {
          case 1:
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: ()  {
                    printTheTable();
                  },
                  child: const Icon(Icons.print),
                ),
                const SizedBox(height: 16), // Adjust the spacing as needed
                FloatingActionButton(
                  onPressed: () {
                    recordNewExpenseDialogue();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            );
          default:
            return Container();
        }
      }(),
      body: Column(
        children: [
          if (widget.tabIndex == 1)
            DatepickerPanel(
              key: UniqueKey(),
              onDateRangeSelected: handleDateRangeSelection,
              startDate: selectedStartDate,
              endDate: selectedEndDate,
            ),
          Expanded(
            child: FutureBuilder<List<List<String>>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading data in the tab ${snapshot.error.toString()}'),
                  );
                } else {
                  return TableWidget(
                    tableData: snapshot.data ?? [],
                    tabIndex: widget.tabIndex,
                    columnNames: getTableColumnNames(widget.tabIndex),
                    columnWidths: getTableColumnWidths(widget.tabIndex),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> getTableColumnNames(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return ['Paid To', 'Amount', 'Date']; // Column names to show messages
      case 1:
        return ['Paid To', 'Amount', 'Date']; // Add your column names for tab 1
      case 2:
        return ['Name', 'Last Balance', 'Last Updated']; // Add your column names for tab 2
      default:
        return [];
    }
  }

  List<double> getTableColumnWidths(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return [MediaQuery.of(context).size.width * 0.30, MediaQuery.of(context).size.width * 0.25, MediaQuery.of(context).size.width * 0.15];
      case 1:
        return [MediaQuery.of(context).size.width * 0.30, MediaQuery.of(context).size.width * 0.25, MediaQuery.of(context).size.width * 0.15];
      case 2:
        return [MediaQuery.of(context).size.width * 0.18, MediaQuery.of(context).size.width * 0.28, MediaQuery.of(context).size.width * 0.35];
      default:
        return [];
    }
  }

  Future<void> recordNewExpenseDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddNewExpenseDialog(
          onComplete: () async { // This `onComplete`is example of a callback that gets called after `AddNewExpenseDialog` widget `complete`s
            tableData = await fetchData(); // Refresh the table data
            setState(() {}); // Trigger a rebuild of the widget
          },
        );
      },
    );
  }

  Future<void> handleDateRangeSelection(DateTime startDate, DateTime endDate) async {
    setState(() {
      selectedStartDate = startDate;
      selectedEndDate = endDate;
    });
    await fetchData();
  }

  Future<void> printTheTable() async{
    bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
    tableData = await fetchData(); // Refresh the table data
    if(debug) log.d('Table data is $tableData');
  }
}
