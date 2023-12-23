import 'package:ExpenseManager/util/data_generator.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
class TableWidget extends StatefulWidget {
  final List<List<String>> tableData;
  final int tabIndex; // Add tabIndex property

  const TableWidget({Key? key, required this.tableData, required this.tabIndex}) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  late List<bool> selectedRows;
  final String _commaOperationName = 'Approve';
  final List<String> COLUMN_NAMES = ['Paid To', 'Amount', 'Date'];
  static final Logger log = Logger();

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  bool isApproving = false; // Flag to track whether the approval process is ongoing

  @override
  void initState() {
    super.initState();
    selectedRows = List.generate(widget.tableData.length, (index) => false);
  }

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
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(COLUMN_NAMES[0]),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              _sortColumn(columnIndex, ascending);
                              setState(() {});
                            },
                            numeric: false,
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(COLUMN_NAMES[1]),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              _sortColumn(columnIndex, ascending);
                              setState(() {});
                            },
                            numeric: false,
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(COLUMN_NAMES[2]),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              _sortColumn(columnIndex, ascending);
                              setState(() {});
                            },
                            numeric: true,
                          ),
                        ],
                        rows: widget.tableData.asMap().entries.map((entry) {
                          final rowIndex = entry.key;
                          final row = entry.value;

                          String col1 = row[0].replaceAll('VPA', '').replaceAll('paytm', '');
                          col1 = col1.length <= 15 ? col1 : col1.substring(0, 15);
                          final String col2 = row[1];
                          final String col3 = row[2];

                          return DataRow(
                            selected: selectedRows[rowIndex],
                            onSelectChanged: (selected) {
                              if (selected != null) {
                                setState(() {
                                  selectedRows[rowIndex] = selected;
                                });
                              }
                            },
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(
                                      col1,
                                      overflow: TextOverflow.clip,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(
                                      col2,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(
                                      col3,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                child: isApproving
                    ? const CircularProgressIndicator() 
                    : Text(_commaOperationName),
              ),
            ),
          ],
        ),
        if (isApproving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Colors.blue.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  // Method to determine whether to show the approved button or not
  bool showApproveButton() {
    return selectedRows.any((selected) => selected) && widget.tabIndex == 0;
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
          message = 'Tab 3 : No data found';
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

  void _sortColumn(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      widget.tableData.sort((a, b) {
        var aValue = a[columnIndex];
        var bValue = b[columnIndex];

        if (columnIndex == 1) {
          return ascending ? int.parse(aValue) - int.parse(bValue) : int.parse(bValue) - int.parse(aValue);
        } else if (columnIndex == 0) {
          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else {
          return 1;
        }
      });
    });
  }

  Future<void> handleApproveSMS() async {
    // Set the flag to true when starting the approval process
    setState(() {
      isApproving = true;
    });

    List<String> recordIds = [];

    for (int i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i]) {
        recordIds.add(widget.tableData[i][3]);
      }
    }

    dynamic response = await DataGenerator.approveSelectedMessages(objAPIName :'FinPlan__SMS_Message__c', recordIds : recordIds);
    log.d('Response for handleApproveSMS ${response.toString()}');

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
