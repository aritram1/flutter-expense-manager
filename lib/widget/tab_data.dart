// tab_data.dart
import 'package:flutter/material.dart';
import './card_widget.dart';
import '../util/data_generator.dart';
import 'package:logger/logger.dart';

class TabData extends StatefulWidget {
  final int tabIndex;
  final String title;
  final bool isCardLayout;
  final Logger log = Logger();

  TabData({Key? key, required this.tabIndex, required this.title, this.isCardLayout = false})
      : super(key: key);

  @override
  State<TabData> createState() => _TabDataState();
}

class _TabDataState extends State<TabData> {
  List<dynamic> _tableData = [];

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    try {
      switch (widget.tabIndex) {
        case 0:
          _tableData = await DataGenerator.generateTab1Data();
          break;
        case 1:
          if (widget.isCardLayout) {
            _tableData = await DataGenerator.generateTab1Data();
          } else {
            _tableData = await DataGenerator.generateTab2Data();
          }
          break;
        case 2:
          _tableData = await DataGenerator.generateTab3Data();
          break;
      }
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tableData == null || _tableData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isCardLayout) {
      return buildCardLayoutWithData(_tableData.cast<Map<String, dynamic>>());
    } else {
      return buildWithData(_tableData);
    }
  }

  Future<List<dynamic>> fetchData() async {
    switch (widget.tabIndex) {
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

  Widget buildCardLayoutWithData(List<Map<String, dynamic>> cardData) {
  return ListView.builder(
    itemCount: cardData.length,
    itemBuilder: (context, index) {
      final data = cardData[index];
      return CardView(
        paidTo: data['beneficiary'],
        amount: data['amount'],
        date: data['date'],
        isCardLayout: true, // Specify that it's a card layout
      );
    },
  );
}


  Widget buildWithData(List<dynamic> tableData) {
  return ListView.builder(
    itemCount: tableData.length,
    itemBuilder: (context, index) {
      final data = tableData[index];
      // Assuming data is a list of strings in this example
      return ListTile(
        title: Text(data['beneficiary']),  // Adjust the key based on your data structure
        subtitle: Text(data['amount']),    // Adjust the key based on your data structure
        trailing: Text(data['date']),       // Adjust the key based on your data structure
        // Additional widgets or customization can be added here
      );
    },
  );
}

}
