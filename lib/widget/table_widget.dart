// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class TableData extends StatefulWidget {
  final int tabIndex;

  const TableData({super.key, required this.tabIndex});

  @override
  _TableDataState createState() => _TableDataState();
}

class _TableDataState extends State<TableData> {
  List<List<String>> tableData = generateTableData();

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Column 1')),
        DataColumn(label: Text('Column 2')),
        DataColumn(label: Text('Column 3')),
      ],
      rows: tableData.map((row) {
        return DataRow(
          cells: [
            DataCell(Text(row[0])),
            DataCell(Text(row[1])),
            DataCell(Text(row[2])),
          ],
        );
      }).toList(),
    );
  }
}

List<List<String>> generateTableData() {
  // Replace this with your data generation logic
  return List.generate(10, (index) {
    return [
      'Row ${index + 1}',
      'Data ${(index + 1) * 2}',
      'Info ${(index + 1) * 3}',
    ];
  });
}
