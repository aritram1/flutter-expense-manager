import 'package:flutter/material.dart';

class FinPlanCard extends StatefulWidget {
  
  const FinPlanCard({super.key, required this.title, required this.icon, required this.onCallBack});

  final String title;
  final Icon icon;
  final Function onCallBack;

  @override
  State<FinPlanCard> createState() => _FinPlanCardState();
}

class _FinPlanCardState extends State<FinPlanCard> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        decoration: BoxDecoration(
          boxShadow: List.filled(10, const BoxShadow(color: Colors.red)),
          color: Colors.amber.shade300,
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   height: 8,
            //   width: 12,
            //   decoration: BoxDecoration(border: Border.all(color: Colors.green)),
            //   child: Center(child : Text(widget.title)),
            // ),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child : widget.icon),
            ),
          ],
        ),
      ),
    ) ;
  }
}

