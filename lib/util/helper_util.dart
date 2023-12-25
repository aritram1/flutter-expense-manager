// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'dart:core';

import 'package:intl/intl.dart';

class HelperUtil {

  static const locale = 'en_IN';

  static String parseDoubleTocurrencyString(double amount, {String locale = locale}) {
    final format = NumberFormat.currency(locale: locale);
    return format.format(amount);
  }

  static double parseCurrencyStringsToDouble(String formattedAmount, {String locale = locale}) {
    final format = NumberFormat.currency(locale: locale);
    return format.parse(formattedAmount).toDouble();
  }


  
}