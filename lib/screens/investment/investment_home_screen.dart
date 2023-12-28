import 'package:flutter/material.dart';
import './investment_screen_0.dart';
import './investment_screen_1.dart';
import '../../widgets/finplan_home_screen_widget.dart';
// import '../../utils/data_generator.dart';
// import 'package:logger/logger.dart';


class InvestmentHomeScreen extends StatelessWidget {
  const InvestmentHomeScreen({Key? key});
  
  @override
  Widget build(BuildContext context) {
    return FinPlanHomeScreenWidget(
      title: 'Investment Home', 
      caller: 'InvestmentHomeScreen',
      tabCount: 2, 
      tabNames: const ['Inv1', 'Inv2'], 
      tabBarViews: [
        InvestmentScreen0(),
        InvestmentScreen1(),
      ],
    );
  }
}