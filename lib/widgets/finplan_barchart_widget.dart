// // ignore_for_file: prefer_const_constructors

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class FinancialData {
//   final String month;
//   final int credit;
//   final int debit;
//   final int savings;

//   FinancialData({
//     required this.month,
//     required this.credit,
//     required this.debit,
//     required this.savings,
//   });
// }

// class FinancialBarChart extends StatelessWidget {
//   final List<FinancialData> data;
//   final Function(FinancialData) onBarTap;
//   final Function onLoadComplete;

//   const FinancialBarChart({super.key, 
//     required this.data,
//     required this.onBarTap,
//     required this.onLoadComplete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final seriesList = _createSeriesList();

//     return BarChart(
//       BarChartData(
//         barGroups: seriesList,
//         titlesData: _createTitlesData(),
//         borderData: FlBorderData(
//           show: false,
//         ),
//         barTouchData: BarTouchData(
//           touchTooltipData: BarTouchTooltipData(
//             tooltipBgColor: Colors.transparent,
//             tooltipPadding: const EdgeInsets.all(0),
//             tooltipMargin: 8,
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               final data = this.data[rodIndex];
//               return BarTooltipItem(
//                 data.month,
//                 TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: '\nCredit: ${data.credit}',
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontSize: 12,
//                     ),
//                   ),
//                   TextSpan(
//                     text: '\nDebit: ${data.debit}',
//                     style: const TextStyle(
//                       color: Colors.red,
//                       fontSize: 12,
//                     ),
//                   ),
//                   TextSpan(
//                     text: '\nSavings: ${data.savings}',
//                     style: const TextStyle(
//                       color: Colors.green,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           touchCallback: (context, barTouchResponse) {
//             // if (barTouchResponse!.spot != null &&
//             //     barTouchResponse.touchInput is! PointerUpEvent) {
//             //   final tappedBar = barTouchResponse.spot!.touchedBarGroup!;
//             //   final tappedIndex = tappedBar.barRods!.indexOf(barTouchResponse.spot!.touchedRodData!);
//             //   onBarTap(data[tappedIndex]);
//             // }
//           },
//         ),
//       ),
//       swapAnimationDuration: Duration(milliseconds: 150),
//       swapAnimationCurve: Curves.linear,
//       domainAxis: _createDomainAxis(),
//       primaryMeasureAxis: _createPrimaryMeasureAxis(),
//       onDrawComplete: () => onLoadComplete(),
//     );
//   }

//   List<BarChartGroupData> _createSeriesList() {
//     return [
//       BarChartGroupData(
//         x: data.map((e) => e.month).toList(),
//         barRods: [
//           BarChartRodData(
//             //y: data.map((e) => e.credit).toList(),
//             color: Colors.blue, 
//             toY: 100,
//           ),
//           BarChartRodData(
//             //y: data.map((e) => e.debit).toList(),
//             colors: [Colors.red],
//           ),
//           BarChartRodData(
//             y: data.map((e) => e.savings).toList(),
//             colors: [Colors.green],
//           ),
//         ],
//       ),
//     ];
//   }

//   FlTitlesData _createTitlesData() {
//     return FlTitlesData(
//       show: true,
//             bottomTitles: SideTitles(
//         showTitles: true,
//         getTextStyles: (context, value) => const TextStyle(
//           color: Colors.black,
//           fontSize: 14,
//         ),
//         margin: 16,
//         rotateAngle: 60,
//       ),
//       leftTitles: SideTitles(
//         showTitles: true,
//         getTextStyles: (context, value) => const TextStyle(
//           color: Colors.black,
//           fontSize: 14,
//         ),
//         margin: 16,
//       ),
//     );
//   }

//   FlAxisTitleData _createDomainAxis() {
//     return FlAxisTitleData(
//       show: true,
//       titleText: 'Months',
//       margin: 16,
//     );
//   }

//   FlAxisTitleData _createPrimaryMeasureAxis() {
//     return FlAxisTitleData(
//       show: true,
//       titleText: 'Amount',
//       margin: 16,
//     );
//   }
// }