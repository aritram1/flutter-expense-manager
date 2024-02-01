// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:ExpenseManager/widgets/util.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FinPlanAddNewInvestmentWidget extends StatefulWidget {
  final Function(String amount, String paidTo, String investmentId, String details, DateTime selectedDate) onSave;

  const FinPlanAddNewInvestmentWidget({Key? key, required this.onSave}) : super(key: key);

  @override
  _FinPlanAddNewInvestmentWidget createState() => _FinPlanAddNewInvestmentWidget();
}

class _FinPlanAddNewInvestmentWidget extends State<FinPlanAddNewInvestmentWidget> {
  static TextEditingController amountController = TextEditingController();
  static TextEditingController paidToController = TextEditingController();
  static TextEditingController detailsController = TextEditingController();
  late DateTime selectedDate; // Declare as late

  final Logger log = Logger();

  static List<dynamic> allInvestments = [];

  static bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    getInvestmentsList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading // depending on isLoading flag, the corresponding widget will be shown
      ? Center(
          child : CircularProgressIndicator(backgroundColor: Colors.transparent,) 
      )
      : AlertDialog(
        title: const Text('Record New Investment'),
        content: FutureBuilder<List<dynamic>>(
          future: Future.value(allInvestments),
          builder: (context, snapshot) {
            // A - Loading indicator when waiting for data
            if(snapshot.connectionState == ConnectionState.waiting){
              return CircularProgressIndicator();
            }
            // B - Handle error
            else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            // C - Data has been received, build the form, Set first value only if not already set
            else{
              if (paidToController.text.isEmpty && snapshot.data!.isNotEmpty) {
                paidToController.text = snapshot.data![0]['Name'];
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: paidToController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        paidToController.text = newValue!;
                      });
                    },
                    items: snapshot.data!.isEmpty
                        ? []
                        : snapshot.data!.map((dynamic each) {
                            return DropdownMenuItem<String>(
                              value: each['Name'],
                              child: Text(each['Name']),
                            );
                          }).toList(),
                    decoration: const InputDecoration(labelText: 'Paid To'),
                  ),
                  TextField(
                    controller: detailsController,
                    decoration: const InputDecoration(labelText: 'Details'),
                  ),
                  Row(
                    children: [
                      Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await _selectDate(context);
                        },
                        child: Text(
                          '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 179, 39, 230),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              );
            }
          },
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
    String investmentId = '';
    for(Map<String, dynamic> each in allInvestments){
      if(each['Name'] == paidTo){
        investmentId = each['Id'];
        break;
      }
    }

    log.d('investment Id => $investmentId');

    if (amount.isNotEmpty && paidTo.isNotEmpty && details.isNotEmpty && investmentId.isNotEmpty) {
      widget.onSave(amount, paidTo, investmentId, details, selectedDate);
      Navigator.of(context).pop();
    } 
    else {
      log.d('All fields are required');
    }
  }

  Future<void> getInvestmentsList() async {
    setState(() {
      isLoading = true;
    });
    
    allInvestments = await Util.getInvestmentsData();
    log.d('data received as=> $allInvestments');
    
    setState(() {
      isLoading = false;
    });

  }
}