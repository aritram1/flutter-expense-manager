// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FinPlanTile extends StatefulWidget {
  
  const FinPlanTile({
    super.key,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.gradientColors,
    this.title, 
    this.topLeft,
    this.topMid,
    this.topRight,
    this.centerLeft,
    this.center,
    this.centerRight,
    this.bottomLeft,
    this.bottomMid,
    this.bottomRight,
    required this.onCallBack
  });

  final double? padding;
  final double? borderRadius;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final String? title;
  final Widget? topLeft;
  final Widget? topMid;
  final Widget? topRight;
  final Widget? centerLeft;
  final Widget? center;
  final Widget? centerRight;
  final Widget? bottomLeft;
  final Widget? bottomMid;
  final Widget? bottomRight;
  final Function onCallBack;
  @override
  State<FinPlanTile> createState() => _FinPlanTileState();
}

class _FinPlanTileState extends State<FinPlanTile> {

  //declare state variables
  late double padding;
  late double borderRadius;
  late Color borderColor;
  late double iconPadding;
  late List<Color> gradientColors;

  static final Logger log = Logger();
  
  @override
  void initState() {
    // initialize state variables
    padding = widget.padding ?? 8.0;
    borderRadius = widget.borderRadius ?? 20;
    borderColor = widget.borderColor ?? Colors.amber.shade500;
    gradientColors = widget.gradientColors ?? [Colors.purple.shade100, Colors.purple.shade200];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return 
    Padding(
      padding: EdgeInsets.all(0.0),
      child: GestureDetector(
        onTap: (){
          log.d('Callback is invoked for the widget!');
          widget.onCallBack();
        },
        child: Container(
          decoration:BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
          
              // Position 1 : Top left
              Visibility(
                visible: widget.topLeft != null,
                child: Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.topLeft,
                  )
                ),
              ),
          
              // Position 2 : Top Middle
              Visibility(
                visible: widget.topMid != null,
                child: Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.topMid,
                  )
                ),
              ),
          
              // Position 3 : Top Right
              Visibility(
                visible: widget.topRight != null,
                child: Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.topRight,
                  )
                ),
              ),
          
              // Position 4 : Center Left
              Visibility(
                visible: widget.centerLeft != null,
                child: Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.centerLeft,
                  )
                ),
              ),
              
              // Position 5 : Center
              Visibility(
                visible: widget.center != null,
                child: Center(
                  child: widget.center,
                ),
              ),
          
              // Position 6 : Center Right
              Visibility(
                visible: widget.centerRight != null,
                child: Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.centerRight,
                  )
                ),
              ),
          
              // Position 7 : Bottom Left
              Visibility(
                visible: widget.bottomLeft != null,
                child: Positioned(
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.bottomLeft,
                  )
                ),
              ),
          
              // Position 8 : Bottom Middle
              Visibility(
                visible: widget.bottomMid != null,
                child: Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.bottomMid,
                  )
                ),
              ),
          
              // Position 9 : Bottom Right
              Visibility(
                visible: widget.bottomRight != null,
                child: Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: widget.bottomRight,
                  )
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
    
}

