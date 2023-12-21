class TabContent{}


// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import '../widget/date_picker_panel.dart';
// import '../widget/table_widget.dart';
// import '../util/data_generator.dart';

// class TabContent extends StatelessWidget {
//   final int tabIndex;
//   final DateTime startDate;
//   final DateTime endDate;
//   final Function(DateTime, DateTime) onDateRangeSelected;

//   const TabContent({
//     Key? key,
//     required this.tabIndex,
//     required this.startDate,
//     required this.endDate,
//     required this.onDateRangeSelected,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (tabIndex == 1)
//           DatepickerPanel(
//             startDate: startDate,
//             endDate: endDate,
//             onDateRangeSelected: onDateRangeSelected,
//           ),
//         Expanded(
//           child: FutureBuilder<List<List<String>>>(
//             future: fetchData(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               } else if (snapshot.hasError) {
//                 return Center(
//                   child: Text('Error loading data in the tab ${snapshot.error.toString()}'),
//                 );
//               } else {
//                 return TableWidget(tableData: snapshot.data ?? [], tabIndex: tabIndex);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Future<List<List<String>>> fetchData() async {
//     switch (tabIndex) {
//       case 0:
//         return await DataGenerator.generateTab1Data();
//       case 1:
//         return await DataGenerator.generateTab2Data(startDate, endDate);
//       case 2:
//         return DataGenerator.generateTab3Data();
//       default:
//         return [];
//     }
//   }
// }
