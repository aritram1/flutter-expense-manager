// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class FinPlanTileMedium extends StatefulWidget {
  
  FinPlanTileMedium({
    super.key,
    required this.height, 
    required this.width, 
    this.borderRadius = 20, 
    this.borderColor = Colors.red,//Colors.amber.shade500,
    required this.title, 
    required this.tl,
    required this.tr, 
    required this.bl, 
    required this.br, 
    required this.centre, 
    required this.onCallBack
  });

  final double height;
  final double width;
  final double borderRadius;
  final Color borderColor;
  final String title;
  final Widget tl;
  final Widget tr;
  final Widget bl;
  final Widget br;
  final Widget centre;
  final Function onCallBack;

  @override
  State<FinPlanTileMedium> createState() => _FinPlanTileMediumState();
}

class _FinPlanTileMediumState extends State<FinPlanTileMedium> {

  @override
  Widget build(BuildContext context) {
    double padding = 4.0;
    double h = widget.height > 100 ? widget.height : 100;
    double w = widget.width > 100 ? widget.width : 100;
    double borderRadius = widget.borderRadius;
    Color borderColor = widget.borderColor;
    return 
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: h,
        width: w,
        decoration:BoxDecoration(
          // color : Colors.red,
          gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade500, Colors.amber.shade600]),
          border: Border.all(
            color: borderColor,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            // Center(
            //   child: Text(widget.title)
            // ),
            Positioned(
              top: 0,
              left: 0,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: widget.tl,
              )
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: widget.tr,
              )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: widget.bl,
              )
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: widget.br,
              )
            ),
            Center(
              child: widget.centre
            ),
          ]
        ),
      ),
    );
  }
    
}

