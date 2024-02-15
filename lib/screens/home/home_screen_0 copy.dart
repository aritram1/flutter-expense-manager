
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';

import 'package:ExpenseManager/screens/home/home_data_generator.dart';
import 'package:ExpenseManager/widgets/V2/finplan_tile.dart';
import 'package:ExpenseManager/widgets/finplan_listview_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class HomeScreen0 extends StatefulWidget {
  const HomeScreen0({super.key});

  @override
  HomeScreen0State createState() => HomeScreen0State();

}

class HomeScreen0State extends State<HomeScreen0>{

  static final Logger log = Logger();

  // DateTime startDate = DateTime.now().add(const Duration(days: -365));
  // DateTime endDate = DateTime.now();

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from HomeScreen0 => $result');
  };

  Future<List<Map<String, dynamic>>> data = Future.value([]);

  @override
  void initState() {
    super.initState();
    data = getDataForLast1Year();
  }

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width*0.9;
    double screenHeight = MediaQuery.of(context).size.height*0.9;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder(
          future: data,
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } 
            else if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading data in HomeScreen0'),
              );
            } 
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : const [
                    Text('No data available,'), 
                    Text('please check messages are approved'),
                    Text('in expense tab'), 
                    SizedBox(height: 12.0),
                    Icon(Icons.refresh),
                  ]
                );
            } 
            else {
              return 
                SingleChildScrollView(
                  child: Column(
                    children:getChartData(snapshot.data, screenHeight, screenWidth),
                    // more to be added here
                    //
                    //
                  )
                );

              // return Expanded(
              //   child: FinPlanListViewWidget(
              //     data : snapshot.data ?? [],
              //     onComplete: (String a, String b){},
              //   )
              // );

              // return FinPlanTableWidget(
              //   headerNames: const ['Paid To', 'Amount', 'Date'],
              //   noRecordFoundMessage: 'Nothing to display',
              //   caller: 'HomeScreen0',
              //   columnWidths: const [0.3, 0.2, 0.1],
              //   data: snapshot.data!,
              //   onLoadComplete: onLoadComplete,
              //   defaultSortcolumnName: 'Date',
              // );
            }
          },
        ),
      ],
    );
  }
    
  // Generate the data for Last 1 year
  Future<List<Map<String, Map<String, dynamic>>>> getDataForLast1Year() {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.add(Duration(days: -350));
    return HomeDataGenerator.generateDataForHomeScreen0(startDate: startDate, endDate: endDate);
  }
    
  getChartData(List<Map<String, dynamic>>? data, double screenHeight, double screenWidth) {
    
    // If data is null just return
    if(data == null) return;

    late String timeFrame;
    late String month;
    late String year;
    late double debit;
    late double credit;
    late double savings;
    late Color color;
    
    List<Widget> widgetList = [];

    for(Map<String, dynamic> item in data){
      for (String key in item.keys) { // Get the month value
        timeFrame = key;
        month = timeFrame.split(' ')[0];
        year = timeFrame.split(' ')[1];
      }
      log.d('item $item');
      log.d('month $month, year $year');

      // Now use the month value ot get other data
      debit = item[timeFrame]['Debit'];
      credit = item[timeFrame]['Credit'];
      savings = credit - debit;

      // IconData iconData = savings >= 0 ? Icons.savings : Icons.paid;

      // convert the month number to name (e.g. 01 translates to January)
      // int numericMonth = int.tryParse(month) ?? 1;
      month = DateFormat('MMMM yyyy').format(DateTime.parse('$year-$month-01'));
      
      widgetList.add(
        SizedBox(
          height: 120,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FinPlanTile(
              borderColor: Colors.amber,
              title:'Hello World!',
              color : savings > 0 ? Colors.green.shade100 : Colors.amber,
              centerLeft: Icon(Icons.spa_rounded),
              topRight: Text(month),
              topLeft: Text(NumberFormat.currency(locale: 'en_IN').format(credit)),
              center: Text(NumberFormat.currency(locale: 'en_IN').format(savings)),
              bottomLeft: Text(NumberFormat.currency(locale: 'en_IN').format(debit)),
              centerRight: Icon(Icons.navigate_next),
              onCallBack: () {
                log.d('This is captured as');
              },
            ),
          ),
        )
      );
    }
    return widgetList;
  }
}