// tab_data.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widget/datepicker_widget.dart'; // Import the SecondTabPanel
import 'table_widget.dart';
import '../widget/expense_entry_dialog.dart';
import '../util/data_generator.dart'; // Import the DataGenerator

class TabData extends StatefulWidget {
  final int tabIndex;
  final String title;

  const TabData({Key? key, required this.tabIndex, required this.title})
      : super(key: key);

  @override
  _TabDataState createState() => _TabDataState();
}

class _TabDataState extends State<TabData> {
  List<List<String>> tableData = [];
  final Logger log = Logger();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await fetchData();
  }

  Future<List<List<String>>> fetchData() async {
    switch (widget.tabIndex) {
      case 0:
        // tableData = await DataGenerator.generateTab1Data();
        return await DataGenerator.generateTab1Data();
      case 1:
        return await DataGenerator.generateTab2Data(selectedDate);
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
            // case 0:
            //   return FloatingActionButton(
            //     onPressed: () {
            //       _showDataEntryDialog();
            //     },
            //     child: const Icon(Icons.add),
            //   );
            case 1:
              return FloatingActionButton(
                onPressed: () {
                  recordNewExpenseDialogue();
                },
                child: const Icon(Icons.add),
              );
            // case 2:
            //   return FloatingActionButton(
            //     onPressed: () {
            //       recordNewExpenseDialogue();
            //     },
            //     child: const Icon(Icons.add),
            //   );
            default:
              return Container(); // or any default widget if needed
          }
        }(),

      body: widget.tabIndex == 1
          ? Column(
              children: [
                DatepickerPanel(
                  key: UniqueKey(),
                  onDateSelected: handleDateSelection,
                  selectedDate: selectedDate,
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
                        return TableWidget(tableData: snapshot.data ?? []); // a blank array is passed to initiate `tableData`
                      }
                    },
                  ),
                ),
              ],
            )
          : FutureBuilder<List<List<String>>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading data'),
                  );
                } else {
                  return TableWidget(tableData: snapshot.data ?? []);
                }
              },
            ),
    );
  }

  Future<void> recordNewExpenseDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DataEntryDialog(
          onSave: (amount, paidTo, details, txnDate) {
            // Handle data entry logic here
            log.d('Amount: $amount');
            log.d('Paid To: $paidTo');
            log.d('Details: $details');
            log.d('Selected Date: $txnDate');

            _fetchData(); // Refresh the table data
          },
        );
      },
    );
  }

  Future<void> handleDateSelection(DateTime date) async {
    setState(() {
      selectedDate = date;
    });

    // Refresh the table data based on the selected date
    await _fetchData();
  }
}
