import 'package:ExpenseManager/widgets/finplan_listview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import './screens/expense/expense_home_screen.dart';
import './screens/home/home_home_screen.dart';
import './screens/investment/investment_home_screen.dart';
import './services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

// Define navigatorKey as a global key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {

  // initialize dot env
  await dotenv.load(fileName: ".env"); 

  // initialize the db
  WidgetsFlutterBinding.ensureInitialized();
  final isDbCreated = await DatabaseService.instance.initializeDatabase();
  Logger().d('Created > $isDbCreated');

  // If not granted, request for permissions (sms read etc) on app startup
  PermissionStatus status = await Permission.sms.status;
  if (status != PermissionStatus.granted) {
    await Permission.sms.request();
  }
  
  // to be implemented : urgent
  // await checkAndRequestPermissions();

  // Run the app finally
  runApp(const MyApp());
  
}

// to be implemented : urgent

// // Check if the SMS permission is granted, if not, request the permission
// // If Permission is still not granted, show an alert dialog
// Future<void> checkAndRequestPermissions() async {
//   // Check if the SMS permission is granted
//   PermissionStatus status = await Permission.sms.status;

//   if (status != PermissionStatus.granted) {
//     // Request the permission
//     PermissionStatus response = await Permission.sms.request();

//     if (response != PermissionStatus.granted) {
//       // Permission is still not granted, show an alert dialog
//       await showDialog(
//         context: navigatorKey.currentContext!,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Please provide the permissions to let the app work properly!'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Open app settings so the user can manually enable the permission
//                       await openAppSettings();
//                     },
//                     child: const Text('Go to Settings'),
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }
//   }
// }
  
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Set to true for debug build
      title: 'Expenso',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyAppHomePage(),
    );
  }
}

class MyAppHomePage extends StatefulWidget {
  const MyAppHomePage({super.key});

  @override
  _MyAppHomePageState createState() => _MyAppHomePageState();
}

class _MyAppHomePageState extends State<MyAppHomePage> {
  
  static int _currentIndex = int.parse(dotenv.env['landingTabIndex'] ?? '0'); // 0 : HomeScreen, 1 : ExpenseHomeScreen, 2 : InvestmentHomeScreen
  
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
            icon: Icon(Icons.currency_rupee),
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
        return const ExpenseHomeScreen();
      case 2:
        return const InvestmentHomeScreen();
      default:
        return Container(); // Handle unknown index gracefully
    }
  }

}