// class FinancialChartSwitch extends StatefulWidget {
//   final List<FinancialData> data;
//   final Function(FinancialData) onBarTap;

//   const FinancialChartSwitch({
//     required this.data,
//     required this.onBarTap,
//   });

//   @override
//   State<FinancialChartSwitch> createState() => _FinancialChartSwitchState();
// }

// class _FinancialChartSwitchState extends State<FinancialChartSwitch> {
//   // Internal state variable to store the currently selected chart type
//   String _selectedChartType = 'By Month';

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedChartType = 'By Month';
//                 });
//               },
//               child: Text(
//                 'By Month',
//                 style: TextStyle(
//                   color: _selectedChartType == 'By Month'
//                       ? Theme.of(context).primaryColor
//                       : Theme.of(context).textTheme.bodyText1!.color,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedChartType = 'By Expense Type'; // Replace with actual expense type switch logic
//                 });
//               },
//               child: Text(
//                 'By Expense Type', // Replace with actual expense type button label
//                 style: TextStyle(
//                   color: _selectedChartType == 'By Expense Type'
//                       ? Theme.of(context).primaryColor
//                       : Theme.of(context).textTheme.bodyText1!.color,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         _buildSelectedChart(),
//       ],
//     );
//   }

//   Widget _buildSelectedChart() {
//     switch (_selectedChartType) {
//       case 'By Month':
//         return FinancialBarChart(
//           data: widget.data,
//           onBarTap: widget.onBarTap,
//           onLoadComplete: () {}, // Update this callback if needed
//         );
//       case 'By Expense Type': // Replace with actual expense type chart widget
//         return Text('Coming soon!'); // Replace with actual widget construction
//       default:
//         return Text('Invalid chart type');
//     }
//   }
// }
