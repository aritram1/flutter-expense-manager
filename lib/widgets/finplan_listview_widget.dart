// ignore_for_file: prefer_const_constructors

import 'package:ExpenseManager/screens/home/home_data_generator.dart';
import 'package:ExpenseManager/utils/data_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../utils/finplan_exception.dart';

class FinPlanListViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Function(String a, String b) onComplete;

  const FinPlanListViewWidget({
    Key? key,
    required this.data,
    required this.onComplete,
  }): super(key: key);

  @override
  FinPlanListViewWidgetState createState() => FinPlanListViewWidgetState();
}

class FinPlanListViewWidgetState extends State<FinPlanListViewWidget> {

  late List<Map<String, dynamic>> items;
  // late Future<List<Map<String, dynamic>>> itemsFuture;

  @override
  void initState(){
    super.initState();
    items = widget.data; // generateData();
  }

  // generateData() async{
  //   return Future.value(HomeDataGenerator.generateDataForHomeScreen0());
  // }

  @override
  Widget build(BuildContext context) {
    return 
      Column(
        children: [
          Expanded(
            child: 
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index){
                Map<String, dynamic> item = items[index];
                return 
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: 
                    Column(
                      children : 
                        [
                          getListTileWidget(item : item, color: Colors.lightGreen)
                        ]
                    )
                );
              },
            ),
          ),
          // Expanded(
          //   child: 
          //   ListView.builder(
          //     itemCount: items.length,
          //     itemBuilder: (context, index){
          //       Map<String, dynamic> item = items[index];
          //       return 
          //       Padding(
          //         padding: const EdgeInsets.all(2.0),
          //         child: 
          //           Column(
          //             children : 
          //               [
          //                 getListTileWidget(item : item, color: Colors.lightBlue)
          //               ]
          //           )
          //       );
          //     },
          //   )
          // ),
        ],
      );
  }
  
  Widget getListTileWidget({required Map<String, dynamic> item, required Color? color}) {
    IconData iconData = item['icon'] ?? Icons.access_alarm;
    String paidTo = item['Paid To']!.toString();
    DateTime date = item['Date']; // DateFormat('YYYY-MM-DD').format( as DateTime).toString();
    double amount = item['Amount'];
    return 
    Card(
      color: color ?? Colors.grey,
      child : 
      ListTile(
        leading: 
          Padding( 
            padding: EdgeInsets.only(left : 12.0),
            child: Icon(iconData),
          ),
        title: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Text(NumberFormat.currency(locale: 'en_IN').format(amount)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SizedBox(
            child: Text(paidTo),
          ),
        ),
        trailing:  Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: Text(DateFormat('dd-MM-yyyy').format(date)),
        ),
        // tileColor: Colors.amber,
        contentPadding: EdgeInsets.all(2.0),
      )
    );
  }
  

}