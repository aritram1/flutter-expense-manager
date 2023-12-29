// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings
import 'package:http/http.dart' as http;

String cId = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  String challenge = '7cKBQeEB79pUtVDTetGjmiHnvvuWuD106pjqcvxyrbM=';
  String verif = 'O9LnlwQ-lDzUVsI0mu7mMbnqKHtQ-Lx9yRouSEkcojk=';

  String url = 'http://localhost/?code=aPrx_yTkbIprMMh05N6wijq59SSlpf6z62Ltk.7.s9HksDl1JJStG4l0RxuQUoQK_.sudxCCXQ%3D%3D';
  Uri uri = Uri.parse(url);
  String authCode = uri.queryParameters['code'] ?? 'nai nai';
  // print('authCode => $authCode');
  

  String tePoint = 'https://login.salesforce.com/services/oauth2/token';

  final String tokenAuthorizationUrl = '$tePoint?' + 
  'grant_type=authorization_code&' +
  'client_id=$cId&' +
  'redirect_uri=$redirectUri&' + 
  'code=$authCode&' +
  'code_verifier=$verif';
  const String redirectUri = 'http://localhost';

  void main() async{
    print('tokenAuthorizationUrl => $tokenAuthorizationUrl');
    
    print('----------------------------------------------------------------------');

    // 6: Call token endpoint to get auth token
    final dynamic authTokenResponse = await http.post(Uri.parse(tokenAuthorizationUrl), headers: {'Content-Type': 'application/json'});
    print('authTokenResponse Body => ${authTokenResponse.body})');
    print('----------------------------------------------------------------------');
  }
