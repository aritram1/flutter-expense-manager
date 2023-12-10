// expense_entry_dialog.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../util/data_generator.dart';
import 'package:logger/logger.dart';

class DataEntryDialog extends StatefulWidget {
  final Function(String, String, String, DateTime) onSave;

  const DataEntryDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _DataEntryDialogState createState() => _DataEntryDialogState();
}

class _DataEntryDialogState extends State<DataEntryDialog> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidToController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  static Logger log = Logger();

  @override
  void dispose() {
    amountController.dispose();
    paidToController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Data Entry'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: paidToController,
              decoration: const InputDecoration(labelText: 'Paid To'),
            ),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            const SizedBox(height: 8.0),
            Row(
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate input fields
            if (_validateFields()) {
              // Handle data entry logic here
              saveNewExpenseToSalesforce(
                amountController.text,
                paidToController.text,
                detailsController.text,
                selectedDate,
              );

              // Close the dialog
              Navigator.of(context).pop();
            } else {
              // Show validation error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields.'),
                ),
              );
            }
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _validateFields() {
    return amountController.text.isNotEmpty &&
        paidToController.text.isNotEmpty &&
        detailsController.text.isNotEmpty;
  }

  // Your custom Salesforce save logic
  void saveNewExpenseToSalesforce(String amount, String paidTo, String details, DateTime selectedDate) async {
    String result = await DataGenerator.addExpenseToSalesforce(amount, paidTo, details, selectedDate);
    log.d('Result from expense entry dialogue : $result');
  }
}
