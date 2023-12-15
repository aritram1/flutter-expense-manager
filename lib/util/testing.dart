import 'package:ExpenseManager/util/salesforce_util%20copy.dart';

import './salesforce_util2.dart';
import 'package:logger/logger.dart';

test(){
  Logger log = Logger();
  dynamic loginRespone = SalesforceUtil79.loginToSalesforce();
  log.d('Login response =>$loginRespone');
}