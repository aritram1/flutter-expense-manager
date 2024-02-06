// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ExpenseTypePillsWidget extends StatelessWidget {
  const ExpenseTypePillsWidget({
    super.key,
    required this.expenseTypes,
    required this.onPillSelected,
  });

  final Set<String> expenseTypes;
  final Function onPillSelected;

  @override
  Widget build(BuildContext context) {
    String selectedPillName = '';
    return Container(
      decoration: BoxDecoration(
        //color: Colors.blue.shade50, // Set your desired background color
        borderRadius: BorderRadius.circular(5), // Make borders circular
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          for (String eachType in expenseTypes)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () {
                  selectedPillName = eachType;
                  onPillSelected(selectedPillName);
                },
                child: Text(
                  eachType,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ]
      ),
    );
  }
}