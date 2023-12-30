import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import './screens/expense/expense_home_screen.dart';
import './screens/home/home_home_screen.dart';
import './screens/investment/investment_home_screen.dart';
import './services/database_service.dart';

void main() async {
  await dotenv.load(fileName: ".env"); 
  WidgetsFlutterBinding.ensureInitialized();
  final isDbCreated = await DatabaseService.instance.initializeDatabase();
  Logger().d('Created > $isDbCreated');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyAppHomePage(),
    );
  }
}

class MyAppHomePage extends StatefulWidget {
  @override
  _MyAppHomePageState createState() => _MyAppHomePageState();
}

class _MyAppHomePageState extends State<MyAppHomePage> {
  int _currentIndex = 0; // 0 : HomeScreen, 1 : ExpenseHomeScreen, 2 : InvestmentHomeScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Investment',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return ExpenseHomeScreen();
      case 2:
        return const InvestmentHomeScreen();
      default:
        return Container(); // Handle unknown index gracefully
    }
  }
}