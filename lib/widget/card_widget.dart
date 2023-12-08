import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  final String paidTo;
  final String amount;
  final String date;
  final bool isCardLayout; // New property

  const CardView({
    Key? key,
    required this.paidTo,
    required this.amount,
    required this.date,
    this.isCardLayout = false, // Default to non-card layout
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCardLayout) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Text(paidTo[0]),
          ),
          title: Text(paidTo),
          subtitle: Text(amount),
          trailing: Text(date),
        ),
      );
    } else {
      // Non-card layout implementation
      return ListTile(
        title: Text(paidTo),
        subtitle: Text(amount),
        trailing: Text(date),
      );
    }
  }
}
