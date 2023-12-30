import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FinPlanAddNewExpenseWidget extends StatefulWidget {
  final Function(String, String, String, DateTime) onSave;

  const FinPlanAddNewExpenseWidget({Key? key, required this.onSave}) : super(key: key);

  @override
  _FinPlanAddNewExpenseWidgetState createState() => _FinPlanAddNewExpenseWidgetState();
}

class _FinPlanAddNewExpenseWidgetState extends State<FinPlanAddNewExpenseWidget> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidToController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  late DateTime selectedDate; // Declare as late

  final Logger log = Logger();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Initialize in initState
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Expense Data'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: paidToController,
            decoration: const InputDecoration(labelText: 'Paid To'),
          ),
          TextField(
            controller: detailsController,
            decoration: const InputDecoration(labelText: 'Details'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _selectDate(context);
            },
            child: const Text('Select Date'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _saveData();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      log.d('selected date $picked');
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveData() {
    String amount = amountController.text;
    String paidTo = paidToController.text;
    String details = detailsController.text;

    if (amount.isNotEmpty && paidTo.isNotEmpty && details.isNotEmpty) {
      widget.onSave(amount, paidTo, details, selectedDate);
      Navigator.of(context).pop();
    } else {
      // Handle empty fields
      log.d('All fields are required');
    }
  }
}
