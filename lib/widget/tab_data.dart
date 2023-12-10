// tab_data.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_phone_app/widget/datepicker_widget.dart';
import 'table_widget.dart';
import 'package:logger/logger.dart';
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
    if (widget.tabIndex == 1) {
      tableData = await DataGenerator.generateTab2Data(selectedDate);
    } else {
      tableData = await fetchData();
    }

    setState(() {});
  }

  Future<List<List<String>>> fetchData() async {
    switch (widget.tabIndex) {
      case 0:
        return await DataGenerator.generateTab1Data();
      case 2:
        return DataGenerator.generateTab3Data();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show data entry screen
          _showDataEntryDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: widget.tabIndex == 1
          ? Column(
              children: [
                SecondTabPanel(
                  onDateSelected: handleDateSelection,
                ),
                Expanded(
                  child: tableData.isNotEmpty
                      ? TableWidget(tableData: tableData)
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ],
            )
          : tableData.isNotEmpty
              ? TableWidget(tableData: tableData)
              : const Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }

  Future<void> _showDataEntryDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DataEntryDialog(
          onSave: (amount, paidTo, details, selectedDate) {
            // Handle data entry logic here
            log.d('Amount: $amount');
            log.d('Paid To: $paidTo');
            log.d('Details: $details');
            log.d('Selected Date: $selectedDate');

            // You can process the data or save it as needed
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