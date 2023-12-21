import 'package:flutter/material.dart';
import 'package:ExpenseManager/util/data_generator.dart';
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
                        columns: List.generate(widget.columnNames.length, (index) {
                          return DataColumn(
                            label: SizedBox(
                              width: widget.columnWidths[index],
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(widget.columnNames[index]),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              _sortColumn(columnIndex, ascending);
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
                child: isApproving ? const CircularProgressIndicator() : Text('Approve'),
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

  // Method to determine whether to show the approved button or not
  bool showApproveButton() {
    return selectedRows.any((selected) => selected) && widget.tabIndex == 0;
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
