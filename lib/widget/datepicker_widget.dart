import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:logger/logger.dart';

class DatepickerPanel extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onDateRangeSelected;

  final Logger log = Logger();

  DatepickerPanel({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  _DatepickerPanelState createState() => _DatepickerPanelState();
}

class _DatepickerPanelState extends State<DatepickerPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Start Date:'),
                TextButton(
                  onPressed: () => _selectDate(context, widget.startDate, widget.onDateRangeSelected, startOrEndDate: 'start'),
                  child: Text(
                    DateFormat('MM-dd-yyyy').format(widget.startDate), // Format the date
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('End Date:'),
                TextButton(
                  onPressed: () => _selectDate(context, widget.endDate, widget.onDateRangeSelected, startOrEndDate: 'end'),
                  child: Text(
                    DateFormat('MM-dd-yyyy').format(widget.endDate), // Format the date
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime selectedDate, Function(DateTime, DateTime) onDateRangeSelected, {required String startOrEndDate}) async {
    final DateTime? picked;

    if (startOrEndDate == 'start') {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: widget.startDate,
        lastDate: DateTime.now(),
      );
    }

    if (picked != null) {
      // Update the selected date in the parent widget
      if (startOrEndDate == 'start') {
        onDateRangeSelected(picked, widget.endDate);
      } else {
        onDateRangeSelected(widget.startDate, picked);
      }
      setState(() {}); // Trigger a rebuild of the widget when the date changes
    }
  }

}