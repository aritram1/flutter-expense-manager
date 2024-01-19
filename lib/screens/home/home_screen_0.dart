
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:ExpenseManager/screens/home/home_data_generator.dart';
import 'package:ExpenseManager/test/testing.dart';
import 'package:ExpenseManager/widgets/finplan_listview_widget.dart';
import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class HomeScreen0 extends StatefulWidget {
  const HomeScreen0({super.key});

  @override
  HomeScreen0State createState() => HomeScreen0State();

}

class HomeScreen0State extends State<HomeScreen0>{

  static final Logger log = Logger();

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from HomeScreen0 => $result');
  };

  @override
  Widget build(BuildContext context) {
    return 
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: generateData(),
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
                return 
                // const Center(child: 
                Column( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children : [
                      Text('No data available in HomeScreen0'),
                      SizedBox(height: 12.0),
                      Icon(Icons.refresh),
                    ]
                  );
                //);
              } 
              else {
                return Expanded(
                  child: FinPlanListViewWidget(
                    data : snapshot.data ?? [],
                    onComplete: (String a, String b){},
                  )
                );

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
    
    // A layer is added
    Future<List<Map<String, dynamic>>> generateData() {
      return HomeDataGenerator.generateDataForHomeScreen0();
    }
  }