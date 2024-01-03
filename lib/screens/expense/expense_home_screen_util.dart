//message_util.dart
// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class ExpenseHomeScreenUtil {

  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  static Logger log = Logger();
  
  
}