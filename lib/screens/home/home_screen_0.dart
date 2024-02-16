
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:ExpenseManager/routes.dart';
import 'package:ExpenseManager/screens/expense/expense_home_screen.dart';
import 'package:ExpenseManager/screens/expense/expense_screen_2.dart';
import 'package:ExpenseManager/widgets/V2/finplan_month_view.dart';
import 'package:ExpenseManager/widgets/V2/finplan_transaction_view.dart';
import 'package:ExpenseManager/widgets/V2/finplan_tile.dart';
import 'package:flutter/material.dart';
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

  // Future<List<Map<String, dynamic>>> data = Future.value([]);

  // late double screenWidth;
  // late double screenHeight; 

  // late double row1Width;
  late double row1Height;

  // late double row2Width;
  late double row2Height;

  // late double row3Width;
  late double row3Height;

  // late double row4Width;
  late double row4Height;

  // late double row5Width;
  late double row5Height;

  late double padding;
  
  @override
  void initState() {
    super.initState();

    row1Height = 80;
    // row1Width = 80;

    row2Height = 80;

    row3Height = 80;
    // row3Width = 80;

    row4Height = 320;
    // row4Width = 240;

    row5Height = 120;
    // row5Width = 120;

    padding = 4;

    // data = getDataForLast1Year();
  }

  @override
  Widget build(BuildContext context) {  
    return 
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children : [
            // First Row
            /////////////////////////////////////////////// Row 1 ///////////////////////////////////////////
            Row(
              children: [
                // First Row, First Column
                Expanded(
                  flex: 1,
                  child: Container(
                    height: row1Height,
                    // width: row1Width,
                    padding: EdgeInsets.all(padding),
                    child: FinPlanTile(
                      center: Icon(Icons.calendar_month),
                      onCallBack: (){
                        var currentContext = context;
                        navigateTo(currentContext, null);
                      }
                    )
                  ),
                ),
                // First Row, Second Column
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    height: row1Height,
                    // width: row1Width,
                    child: FinPlanTile(
                      center: Icon(Icons.account_balance),
                      onCallBack: (){
                        var currentContext = context;
                        navigateTo(currentContext, null);  
                      }
                    )
                  ),
                ),
                // First Row, Third Column
                Expanded(
                  flex: 2,
                  child: Container(
                    height: row1Height,
                    // width: row1Width,
                    padding: EdgeInsets.all(padding),
                    child: FinPlanTile(
                      center: Icon(Icons.spa),
                      onCallBack: (){
                        var currentContext = context;
                        navigateTo(currentContext, null);
                      }
                    )
                  ),
                ),
              ],
            ),
            /////////////////////////////////////////////// Row 2 ///////////////////////////////////////////
            // Second Row
            Column(
              children: [
                // Second Row, First Column
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: row2Height,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(padding),
                        child: FinPlanTile(
                          center: const Text('Accounts'),
                          topRight: Icon(Icons.arrow_outward),
                          onCallBack: (){
                            var currentContext = context;
                            navigateTo(currentContext, Scaffold(appBar: AppBar(), body : ExpenseScreen2()));
                          }
                        )
                      ),
                    ),
                  ],
                ),
                // Second Row, Second Column
                // Second Row, Third Column
              ],
            ),
            // Third Row
            /////////////////////////////////////////////// Row 3 ///////////////////////////////////////////
            Column(
              children: [
                Row(
                  children: [
                    // Third Row, First Column
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: row3Height,
                        // width: row3Width,
                        padding: EdgeInsets.all(padding),
                        child: FinPlanTile(
                          center: Icon(Icons.message),
                          onCallBack: (){
                            var currentContext = context;
                            navigateTo(currentContext, ExpenseHomeScreen());
                          }
                        )
                      ),
                    ),
                    // Third Row, Second Column
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: row3Height,
                        // width: row3Width,
                        padding: EdgeInsets.all(padding),
                        child: FinPlanTile(
                          center: Icon(Icons.camera),
                          onCallBack: (){
                            var currentContext = context;
                            navigateTo(currentContext, null);  
                          }
                        )
                      ),
                    ),
                    // Third Row, Third Column
                    //
                  ],
                ),
              ],
            ),
            /////////////////////////////////////////////// Row 4 ///////////////////////////////////////////
            // Fourth Row
            Column(
              children: [
                // Fourth Row, First Column
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: row4Height,
                        // width: row4Width,
                        padding: EdgeInsets.all(padding),
                        child: FinPlanTile(
                          center: Icon(Icons.cabin),
                          topRight: Container(
                            height: 80,
                            width: 80,
                            padding: EdgeInsets.all(padding),
                            child: FinPlanTile(
                              borderColor: Colors.purple.shade100,
                              gradientColors: [Colors.purple.shade100, Colors.purple.shade200],
                              center: Icon(Icons.near_me),
                              onCallBack: (){
                                var currentContext = context;
                                navigateTo(currentContext, null);   
                              }
                            ),
                          ),
                          onCallBack: (){
                            var currentContext = context;
                            navigateTo(currentContext, null);  
                          }
                        )
                      ),
                    ),
                  ],
                ),
                // Fourth Row, Second Column
                // Fourth Row, Third Column
              ],
            ),
            // Fifth Row 
            /////////////////////////////////////////////// Row 5 ///////////////////////////////////////////
            Column(
              children: [
                Row(
                  children: [
                    // Fifth Row, First Column
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: row5Height,
                        // width: row5Width,
                        padding: EdgeInsets.all(padding),
                        child: FinPlanTile(
                          center: Icon(Icons.spa),
                          onCallBack: (){
                            var currentContext = context;
                            navigateTo(currentContext, null);  
                          }
                        )
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: row5Height,
                        // width: row5Width,
                        padding: EdgeInsets.all(padding),
                        child: FinPlanTile(
                          center: Icon(Icons.spa),
                          onCallBack: (){
                            var currentContext = context;
                            navigateTo(currentContext, null);  
                          }
                        )
                      ),
                    ),
                    // Fifth Row, Second Column
                    // Fifth Row, Third Column  
                  ],
                ),
              ],
            ),
          ]
        )
      ),
    );
  }
  
  void navigateTo(BuildContext context, Widget? widget) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context)=> widget ??  
          Scaffold(
            appBar: AppBar(), 
            body : Container(
              padding: EdgeInsets.all(8),
              // child: // FinPlanMonthView()
              child: Center(
                child: const Text("Hello Hi there!"),
              ),
            )
          )
      )
    );
  }
}
  
  /*
  @override
  Widget build(BuildContext context) {
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
                    Container(height: 12.0),
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
  */

  // // Generate the data for Last 1 year
  // Future<List<Map<String, Map<String, dynamic>>>> getDataForLast1Year() {
  //   DateTime endDate = DateTime.now();
  //   DateTime startDate = endDate.add(Duration(days: -350));
  //   return HomeDataGenerator.generateDataForHomeScreen0(startDate: startDate, endDate: endDate);
  // }
    
//   getChartData(List<Map<String, dynamic>>? data, double screenHeight, double screenWidth) {
    
//     // If data is null just return
//     if(data == null) return;

//     late String timeFrame;
//     late String month;
//     late String year;
//     late double debit;
//     late double credit;
//     late double savings;
//     late Color color;
    
//     List<Widget> widgetList = [];

//     for(Map<String, dynamic> item in data){
//       for (String key in item.keys) { // Get the month value
//         timeFrame = key;
//         month = timeFrame.split(' ')[0];
//         year = timeFrame.split(' ')[1];
//       }
//       log.d('item $item');
//       log.d('month $month, year $year');

//       // Now use the month value ot get other data
//       debit = item[timeFrame]['Debit'];
//       credit = item[timeFrame]['Credit'];
//       savings = credit - debit;

//       // IconData iconData = savings >= 0 ? Icons.savings : Icons.paid;

//       // convert the month number to name (e.g. 01 translates to January)
//       // int numericMonth = int.tryParse(month) ?? 1;
//       month = DateFormat('MMMM yyyy').format(DateTime.parse('$year-$month-01'));
      
//       widgetList.add(
//         Container(
//           height: 120,
//           width: MediaQuery.of(context).size.width,
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: FinPlanTile(
//               borderColor: Colors.amber,
//               title:'Hello World!',
//               color : savings > 0 ? Colors.green.shade100 : Colors.amber,
//               centerLeft: Icon(Icons.spa_rounded),
//               topRight: Text(month),
//               topLeft: Text(NumberFormat.currency(locale: 'en_IN').format(credit)),
//               center: Text(NumberFormat.currency(locale: 'en_IN').format(savings)),
//               bottomLeft: Text(NumberFormat.currency(locale: 'en_IN').format(debit)),
//               centerRight: Icon(Icons.navigate_next),
//               onCallBack: () {
//                 log.d('This is captured as');
//               },
//             ),
//           ),
//         )
//       );
//     }
//     return widgetList;
//   }
