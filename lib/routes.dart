import 'package:ExpenseManager/screens/expense/expense_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Routes {
  static const String home = '/';
  static const String messages = '/messages';

  static final Logger log = Logger();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    log.d('Settings is => $settings');
    switch (settings.name) {
      // case home:
      //   return MaterialPageRoute(builder: (_) => YourHomePage());
      case messages:
        return MaterialPageRoute(builder: (_) => const ExpenseHomeScreen());
      default:
        // Handle unknown routes
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Unknown Route'))));
    }
  }
}
