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

  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');

  static final log = Logger(); 

  @override
  void initState(){
    super.initState();
    items = widget.data;
  }

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
        ],
      );
  }
  
  Widget getListTileWidget({required item, required Color? color}) {
    late String timeFrame;
    late String month;
    late String year;
    for (String key in item.keys) { // Get the month value
      timeFrame = key;
      month = timeFrame.split(' ')[0];
      year = timeFrame.split(' ')[1];
    }
    log.d('item $item');
    log.d('month $month, year $year');
    // Now use the month value ot get other data
    double debit = item[timeFrame]['Debit'];
    double credit = item[timeFrame]['Credit'];
    double savings = credit - debit;
    Color color = savings >= 0 ? Colors.green.shade100 : Colors.amber.shade100;
    IconData iconData = savings >= 0 ? Icons.savings : Icons.paid;

    // convert the month number to name (e.g. 01 translates to January)
    // int numericMonth = int.tryParse(month) ?? 1;
    month = DateFormat('MMMM yyyy').format(DateTime.parse('$year-$month-01'));

    return 
      Card(
        color: color,
        child : 
        ListTile(
          leading: 
            Padding( 
              padding: EdgeInsets.only(left : 2.0),
              child: Icon(iconData),
            ),
          title: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(month),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.add_circle),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(NumberFormat.currency(locale: 'en_IN').format(credit)),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.outbound),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(NumberFormat.currency(locale: 'en_IN').format(debit)),
                  ),
                ],
              )
            ],
          ),
          trailing:  Padding(
            padding: const EdgeInsets.only(right: 0.0),
            child: Text(NumberFormat.currency(locale: 'en_IN').format(savings)),
          ),
        )
      );
    }

}