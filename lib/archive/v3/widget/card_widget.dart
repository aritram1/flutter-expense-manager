import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  final String paidTo;
  final String amount;
  final String date;

  const CardView({
    Key? key,
    required this.paidTo,
    required this.amount,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}
