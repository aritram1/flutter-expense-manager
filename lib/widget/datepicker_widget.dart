import 'package:flutter/material.dart';

class SecondTabPanel extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const SecondTabPanel({Key? key, required this.onDateSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Select Date:'),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              '${DateTime.now().toLocal()}'.split(' ')[0],
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
