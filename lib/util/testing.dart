import './salesforce_util2.dart';
import 'package:logger/logger.dart';

main() async{

  // Login
  // dynamic loginRespone = await SalesforceUtil2.loginToSalesforce();
  // print('Login response =>${SalesforceUtil2.accessToken}');

  // Insert
  // List<Map<String, String>> allInsert = [];
  // for(int i=0;i<300;i++){
  //   Map<String, String> each = {};
  //   if(i != 100) each['name'] = 'Account - $i';
  //   each['phone'] = '123456$i';
  //   all.add(each);
  // }
  // dynamic insertResponse = await SalesforceUtil2.insertToSalesforce('Account', allInsert);
  // print('Insert response =>$insertResponse');

  // update
  List<String> idList = ['0015i000013UxzYAAS','0015i000013UxzXAAS', '0015i000013UxzOAAS'];
  List<Map<String, String>> allUpdate = [];
  for(int i=0;i<3;i++){
    Map<String, String> each = {};
    each['id'] = idList[i];
    each['accountNumber'] = '${1000*i*i}';
    each['phone'] = '${1000*i*i}';
    allUpdate.add(each);
  }
  dynamic updateResponse = await SalesforceUtil2.updateToSalesforce('Account', allUpdate);
  print('updateResponse =>$updateResponse');


}