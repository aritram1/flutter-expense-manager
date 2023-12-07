// tab_data.dart

import 'package:flutter/material.dart';
import './widget/table_widget.dart';
import './data_generator.dart';

class TabData extends StatelessWidget {
  final int tabIndex;
  final String title;
  
  const TabData({Key? key, required this.tabIndex, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<List<String>> tableData = [];
    
    switch (tabIndex) {
      case 0:
        tableData = DataGenerator.generateTab1Data();
        break;
      case 1:
        tableData = DataGenerator.generateTab2Data();
        break;
      case 2:
        tableData = DataGenerator.generateTab3Data();
        break;
      default:
        break;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement tab-specific floating button logic here
          print('Floating button pressed on $title');
        },
        child: const Icon(Icons.refresh),
      ),
      body: TableWidget(tableData: tableData),
    );
  }
}
