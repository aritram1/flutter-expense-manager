import 'package:ExpenseManager/widgets/finplan_app_home_screen_widget.dart';
import 'package:flutter/material.dart';
import './home_screen_0.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FinPlanAppHomeScreenWidget(
      title: 'Just Home', 
      tabCount: 1, 
      tabNames: const ['Home0'], 
      tabBarViews: const [
        HomeScreen0()
      ],
      caller : 'HomeScreen'
    );
  }
}