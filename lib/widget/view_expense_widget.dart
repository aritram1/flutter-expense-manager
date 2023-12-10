// view_expense_widget.dart
import 'package:flutter/material.dart';

class SecondTabPanel extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const SecondTabPanel({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  _SecondTabPanelState createState() => _SecondTabPanelState();
}

class _SecondTabPanelState extends State<SecondTabPanel> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Select Date:'),
          const SizedBox(width: 8.0),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              '${selectedDate.toLocal()}'.split(' ')[0],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.onDateSelected(selectedDate);
      });
    }
  }
}
