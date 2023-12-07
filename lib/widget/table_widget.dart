// table_widget.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../util/salesforce_util.dart';

class TableWidget extends StatefulWidget {
  final List<List<String>> tableData;

  const TableWidget({Key? key, required this.tableData}) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  late List<bool> selectedRows;
  final String _commaOperationName = 'Approve';
  List<String> COLUMN_NAMES = ['Paid To', 'Amount', 'Date'];
  static final Logger log = Logger();

  @override
  void initState() {
    super.initState();
    selectedRows = List.generate(widget.tableData.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 16.0, // Adjust the spacing between columns
              headingRowHeight: 40.0, // Adjust the height of the heading row
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.grey), // Customize the table border
              ),
              sortAscending: true,
              sortColumnIndex: 0,
              columns: [
                DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(COLUMN_NAMES[0]),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {});
                  },
                  numeric: false,
                ),
                DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(COLUMN_NAMES[1]),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {});
                  },
                  numeric: false,
                ),
                DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(COLUMN_NAMES[2]),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {});
                  },
                  numeric: true,
                ),
              ],
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
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row[0]),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row[1]),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row[2]),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _performCommonOperation();
          },
          child: Text(_commaOperationName),
        ),
      ],
    );
  }

  void _performCommonOperation() {
    List<String> recordIds = [];
    // List<Map<String, dynamic>> fieldValuesMapList = [] ;
    for (int i = selectedRows.length - 1; i >= 0; i--) {
      if (selectedRows[i]) {
        // Map<String, dynamic> fieldValuesMap = {};
        // fieldValuesMap['Id'] = widget.tableData[i][3];
        // fieldValuesMap['FinPlan__Approved__c'] = true;
        log.d('Selected=>${widget.tableData[i]}');
        widget.tableData.removeAt(i);
        selectedRows.removeAt(i);
        recordIds.add(widget.tableData[i][3]);
      }
    }
    log.d('fieldValues inside _performCommonOperation=>$recordIds');
    
    // update in SF
    SalesforceUtil.updateSalesforceData('FinPlan__SMS_Message__c', recordIds);
    
    setState(() {});
  }


}
