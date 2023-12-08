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
  late List<dynamic> _tableData = [];

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    switch (widget.tabIndex) {
      case 0:
        _tableData = await DataGenerator.generateTab1Data();
        break;
      case 1:
        if (widget.isCardLayout) {
          _tableData = await DataGenerator.generateTab1Data(); // Adjust this based on your needs
        } else {
          _tableData = await DataGenerator.generateTab2Data();
        }
        break;
      case 2:
        _tableData = await DataGenerator.generateTab3Data();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tableData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isCardLayout) {
      return buildCardLayoutWithData(_tableData.cast<Map<String, dynamic>>());
    } else {
      return FutureBuilder<List<dynamic>>(
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
        );
      },
    );
  }

  Widget buildWithData(List<dynamic> tableData) {
    // Adjust this method based on your needs
    return Container(
      // Your tabular layout widget goes here
    );
  }
}
