// table_widget.dart

import 'package:flutter/material.dart';

class TableWidget extends StatefulWidget {
  final List<List<String>> tableData;

  const TableWidget({Key? key, required this.tableData}) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  late List<bool> selectedRows;
  final String _commaOperationName = 'Delete';

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
              columns: const [
                DataColumn(label: Text('Row')),
                DataColumn(label: Text('Data')),
                DataColumn(label: Text('Info')),
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
                    DataCell(Text(row[0])),
                    DataCell(Text(row[1])),
                    DataCell(Text(row[2])),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Perform common operation (e.g., delete selected rows)
            // Replace this with your own logic
            _performCommonOperation();
          },
          child: Text(_commaOperationName),
        ),
      ],
    );
  }

  void _performCommonOperation() {
    // Replace this with your own logic for the common operation.
    // For example, deleting selected rows.
    for (int i = selectedRows.length - 1; i >= 0; i--) {
      if (selectedRows[i]) {
        widget.tableData.removeAt(i);
        selectedRows.removeAt(i);
      }
    }
    setState(() {});
  }
}
