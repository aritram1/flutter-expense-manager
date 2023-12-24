import 'package:flutter/material.dart';
import 'package:ExpenseManager/util/data_generator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class TableWidget extends StatefulWidget {
  final List<List<String>> tableData;
  final int tabIndex;
  final List<String> columnNames;
  final List<double> columnWidths;

  const TableWidget({
    Key? key,
    required this.tableData,
    required this.tabIndex,
    required this.columnNames,
    required this.columnWidths,
  }) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  late List<bool> selectedRows;
  static final Logger log = Logger();

  int sortColumnIndex = 0;
  bool _sortAscending = false;
  List<IconData?> _sortIcons = [];
  int onLoadDefaultDescendingColumnId = 2; // default order declared
  
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool bigdebug = bool.parse(dotenv.env['bigdebug'] ?? 'false');

  String approveButtonName = 'Approve';
  bool isApproving = false; // Flag to track whether the approval process is ongoing

  @override
  void initState() {

    super.initState();

    if(widget.tabIndex == 0 || widget.tabIndex == 1){ 
      onLoadDefaultDescendingColumnId = 2;  // By default, on load the table will be sorted by col 2 (i.e. date)
    }
    else{
      onLoadDefaultDescendingColumnId = 0;  // However for third tab (bank account details) sorting will be on col 0 i.e. Name
    }

    selectedRows = List.generate(widget.tableData.length, (index) => false);
    _sortIcons = List.generate(widget.columnNames.length, (colIndex) {
      if (colIndex == 2) {  // This index = 2 means the third column i.e. the `date` column
        _sortAscending = false; // Set the default sort order for the date column to descending
        return Icons.arrow_upward; // Set the default sorting icon for the third column
      } 
      else {
        return null;
      }
    });
    // Sort the data by the third column (date) in descending order initially
    _sortColumn(onLoadDefaultDescendingColumnId);
  }

  // The `build` method of the widget
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: widget.tableData.isEmpty
                  ? _buildEmptyTableMessage()
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 1.0,
                        headingRowHeight: 40.0,
                        sortAscending: _sortAscending,
                        columns: List.generate(widget.columnNames.length, (index) {
                          return DataColumn(
                            label: SizedBox(
                              width: widget.columnWidths[index],
                              child: InkWell(
                                onTap: () {
                                  _sortColumn(index);
                                },
                                child: Row(
                                  children: [
                                    Text(widget.columnNames[index]),
                                    if (_sortIcons[index] != null)
                                      Icon(
                                        _sortIcons[index], 
                                        size: 15.0, // Adjust the size as needed
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              _sortColumn(columnIndex);
                              setState(() {});
                            },
                            numeric: false,
                          );
                        }),
                        rows: widget.tableData.asMap().entries.map((entry) {
                          final rowIndex = entry.key;
                          final row = entry.value;

                          return DataRow(
                            selected: selectedRows[rowIndex],
                            onSelectChanged: (selected) {
                              if (selected != null) {
                                setState(() {
                                  selectedRows[rowIndex] = selected;
                                });
                              }
                            },
                            cells: List.generate(widget.columnNames.length, (index) {
                              return DataCell(
                                SizedBox(
                                  width: widget.columnWidths[index],
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(
                                      row[index],
                                      overflow: TextOverflow.clip,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            Visibility(
              visible: showApproveButton(),
              child: ElevatedButton(
                onPressed: () async {
                  await handleApproveSMS();
                },
                child: isApproving ? const CircularProgressIndicator() : Text(approveButtonName),
              ),
            ),
          ],
        ),
        if (isApproving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyTableMessage() {
    if (widget.tableData.isEmpty) {
      String message;
      switch (widget.tabIndex) {
        case 0:
          message = 'Nothing to approve';
          break;
        case 1:
          message = 'No transactions are available between the dates';
          break;
        case 2:
          message = 'No bank accounts are available to show';
          break;
        // Add more cases if needed
        default:
          message = 'Default Message : No data found';
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // The private `_sort` method
  void _sortColumn(int columnIndex) {
  setState(() {
    for (int i = 0; i < _sortIcons.length; i++) {
      if (i == columnIndex) {
        if (_sortIcons[i] == Icons.arrow_upward) {
          _sortIcons[i] = Icons.arrow_downward;
          _sortAscending = false;
        } else {
          _sortIcons[i] = Icons.arrow_upward;
          _sortAscending = true;
        }
      } else {
        _sortIcons[i] = null;
      }
    }

    sortColumnIndex = columnIndex;

    widget.tableData.sort((a, b) {

      // 0th - this column is string - so normal sorting
      if (columnIndex == 0) {
        String aName = a[columnIndex];
        String bName = b[columnIndex];
        return _sortAscending ? aName.compareTo(bName) : bName.compareTo(aName);
      }
      // 1st - this column is numeric - so some transformation is required from local formated currency to double
      else if (columnIndex == 1) {
        String aAmountValueString = a[columnIndex].replaceAll(',', '').replaceAll('INR', '').replaceAll(' ', '');
        String bAmountValueString = b[columnIndex].replaceAll(',', '').replaceAll('INR', '').replaceAll(' ', '');;
        var aAmountValue = double.parse(aAmountValueString);
        var bAmountValue = double.parse(bAmountValueString);
        return _sortAscending ? aAmountValue.compareTo(bAmountValue) : bAmountValue.compareTo(aAmountValue);
      } 
      // 2nd - this column is date so additional logic is required
      else if (columnIndex == 2) {
        String aDateValue = a[columnIndex];
        String bDateValue = b[columnIndex];
        
        if(bigdebug) log.d('Tabindex is => ${widget.tabIndex}');

        // When its on Messages tab or transactions tab
        if(widget.tabIndex == 0 || widget.tabIndex == 1){
          // just switch the DD/MM format to MM/DD format so they can be string sorted
          aDateValue = '${aDateValue.split('/')[1]}${aDateValue.split('/')[0]}';
          bDateValue = '${bDateValue.split('/')[1]}${bDateValue.split('/')[0]}';
          return _sortAscending ? aDateValue.compareTo(bDateValue) : bDateValue.compareTo(aDateValue);
        }
        else{// To be implemented for third tab // TBD // Urgent
          return 1;
        } 
      }
      else {
        return 1;
      }
    });
  });
}

  bool showApproveButton() {
    return selectedRows.any((selected) => selected) && widget.tabIndex == 0;
  }

  Future<void> handleApproveSMS() async {
    setState(() {
      // Set the flag to true when starting the approval process
      isApproving = true;
    });

    List<String> recordIds = [];

    for (int i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i]) {
        recordIds.add(widget.tableData[i][3]);
      }
    }

    dynamic response = await DataGenerator.approveSelectedMessages(objAPIName: 'FinPlan__SMS_Message__c', recordIds: recordIds);
    
    if(debug) log.d('Response for handleApproveSMS ${response.toString()}');

    setState(() {

      // Reset the flag when the approval process is completed
      isApproving = false;

      for (int i = 0; i < selectedRows.length; i++) {
        if (selectedRows[i]) {
          widget.tableData.removeAt(i);
          selectedRows.removeAt(i);
        }
      }
    });
  }
}
