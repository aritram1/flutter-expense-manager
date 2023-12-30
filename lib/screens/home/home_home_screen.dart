import 'package:flutter/material.dart';
import './home_screen_0.dart';
import '../../widgets/finplan_app_home_screen_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});
  
  @override
  Widget build(BuildContext context) {
    return FinPlanAppHomeScreenWidget(
      title: 'Just Home', 
      tabCount: 1, 
      tabNames: const ['Home0'], 
      tabBarViews: [
        HomeScreen0()
      ],
      caller : 'HomeScreen'
    );
  }
}