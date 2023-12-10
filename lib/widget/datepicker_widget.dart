import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DatepickerPanel extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  Logger log = Logger();

  DatepickerPanel({Key? key, required this.onDateSelected, required this.selectedDate})
      : super(key: key);

  @override
  _DatepickerPanelState createState() => _DatepickerPanelState();
}

class _DatepickerPanelState extends State<DatepickerPanel> {
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
              '${widget.selectedDate.toLocal()}'.split(' ')[0],
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
      initialDate: widget.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      widget.log.d('selected date $picked');
      widget.onDateSelected(picked);
      setState(() {}); // Trigger a rebuild of the widget when the date changes
    }
  }
}
