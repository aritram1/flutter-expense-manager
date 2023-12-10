import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widget/datepicker_widget.dart';
import 'table_widget.dart';
import '../widget/expense_entry_dialog.dart';
import '../util/data_generator.dart';

class TabData extends StatefulWidget {
  final int tabIndex;
  final String title;

  const TabData({Key? key, required this.tabIndex, required this.title}) : super(key: key);

  @override
  _TabDataState createState() => _TabDataState();
}

class _TabDataState extends State<TabData> {
  List<List<String>> tableData = [];
  final Logger log = Logger();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();

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
            return FloatingActionButton(
              onPressed: () {
                recordNewExpenseDialogue();
              },
              child: const Icon(Icons.add),
            );
          default:
            return Container();
        }
      }(),
      body: widget.tabIndex == 1
          ? Column(
              children: [
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
                        return TableWidget(tableData: snapshot.data ?? [], tabIndex: widget.tabIndex);
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
                  return TableWidget(tableData: snapshot.data ?? [], tabIndex: widget.tabIndex);
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
            log.d('Amount: $amount');
            log.d('Paid To: $paidTo');
            log.d('Details: $details');
            log.d('Selected Start Date: $selectedStartDate');
            log.d('Selected End Date: $selectedEndDate');

            _fetchData(); // Refresh the table data
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

    await _fetchData();
  }
}
