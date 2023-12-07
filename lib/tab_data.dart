// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import './widget/table_widget.dart';
import './data_generator.dart';
import 'package:logger/logger.dart';

class TabData extends StatelessWidget {
  final int tabIndex;
  final String title;
  final Logger log = Logger();

  TabData({Key? key, required this.tabIndex, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<String>>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return buildWithData(snapshot.data ?? []);
        }
      },
    );
  }

  Future<List<List<String>>> fetchData() async {
    switch (tabIndex) {
      case 0:
        return await DataGenerator.generateTab1Data();
      case 1:
        return DataGenerator.generateTab2Data();
      case 2:
        return DataGenerator.generateTab3Data();
      default:
        return [];
    }
  }

  Widget buildWithData(List<List<String>> tableData) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement tab-specific floating button logic here
          print('Floating button pressed on $title $tabIndex');
          if(tabIndex == 0){
            fetchData(); //TBD
          }
        },
        child: const Icon(Icons.refresh),
      ),
      body: TableWidget(tableData: tableData),
    );
  }
}
