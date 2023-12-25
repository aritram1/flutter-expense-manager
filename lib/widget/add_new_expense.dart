// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../util/data_generator.dart';

class AddNewExpenseDialog extends StatefulWidget {
  final Function() onComplete;

  const AddNewExpenseDialog({Key? key, required this.onComplete}) : super(key: key);

  @override
  _AddNewExpenseDialogState createState() => _AddNewExpenseDialogState();
}

class _AddNewExpenseDialogState extends State<AddNewExpenseDialog> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidToController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  late DateTime selectedDate;
  late String selectedDateInStringFormat;
  String? errorMessage;
  
  final Logger log = Logger();

  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Initialize in initState
    selectedDateInStringFormat = selectedDate.toString().split(' ')[0]; // Initialize in initState
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Expense Data'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /////////////////////////////////// Error Panel /////////////////////////////////
            if (errorMessage != null) 
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            //////////////////////////////////// Input panel /////////////////////////////////
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
            //////////////////////////////////// Elevated Button panel /////////////////////////////////
            Row(
              children: [
                const Text('Select Date'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _selectDate(context);
                    },
                    child: Text(selectedDateInStringFormat),
                  ),
                ),
              ],
            ),
            //////////////////////////////////// End ///////////////////////////////////////////////////
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
        TextButton(
          onPressed: ()  {
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
      // log.d('selected date $picked');
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveData() async {
    String amount = amountController.text;
    String paidTo = paidToController.text;
    String details = detailsController.text;

    if (amount.isNotEmpty && paidTo.isNotEmpty && details.isNotEmpty) {
      
      Map<String, dynamic> saveDataResponse = await DataGenerator.addExpenseToSalesforce(amount, paidTo, details, selectedDate);
      
      // log.d('saveDataResponse => ${saveDataResponse.toString()}');

      setState(() {
        errorMessage = null;
      }); 

      widget.onComplete(); // This will refresh the tab so we get latest data, this is a way of passing callback
      
      Navigator.of(context).pop();
    } else {
      // Handle empty fields
      // log.d('All fields are required');
      
      setState(() {
        errorMessage = 'All fields are required.';
      });
    }
  }

}
