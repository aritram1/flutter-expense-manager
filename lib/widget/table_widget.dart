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

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

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
              columnSpacing: 1.0,
              headingRowHeight: 40.0,
              sortAscending: _sortAscending,
              columns: [
                DataColumn(
                  label: Container(
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
                  label: Container(
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
                  label: Container(
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
                      Container(
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
                      Container(
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
                      Container(
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
          visible: selectedRows.any((selected) => selected),
          child: ElevatedButton(
            onPressed: _performCommonOperation,
            child: Text(_commaOperationName),
          ),
        ),
      ],
    );
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

  void _performCommonOperation() {
    List<String> recordIds = [];

    for (int i = selectedRows.length - 1; i >= 0; i--) {
      if (selectedRows[i]) {
        recordIds.add(widget.tableData[i][3]);
        log.d('Selected=>${widget.tableData[i]}');
        widget.tableData.removeAt(i);
        selectedRows.removeAt(i);
      }
    }

    log.d('fieldValues inside _performCommonOperation=>$recordIds');

    SalesforceUtil.updateSalesforceData('FinPlan__SMS_Message__c', recordIds);

    setState(() {});
  }
}
