import 'package:flutter/material.dart';

class FinPlanTileSmall extends StatefulWidget {
  
  FinPlanTileSmall({super.key, required this.title, required this.icon, required this.onCallBack});

  String title;
  Icon icon;
  Function onCallBack;

  @override
  State<FinPlanTileSmall> createState() => _FinPlanTileSmallState();
}

class _FinPlanTileSmallState extends State<FinPlanTileSmall> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 60,
        width: 60,
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
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: widget.onCallBack(),
                child : widget.icon
              ),
            ),
          ],
        ),
      ),
    ) ;
  }
}

