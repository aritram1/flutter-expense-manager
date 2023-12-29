// ignore_for_file: avoid_print, prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';

void main() async {
  final Logger log = Logger();

  print('Logging...');

  // SF constant endpoints
  final String authorizationEndpoint = 'https://login.salesforce.com/services/oauth2/authorize';
  String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';

  // SF instant specific constants
  const String clientId = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  const String redirectUri = 'http://localhost';

  print('----------------------------------------------------------------------');
  // 1. Generate code verifier
  final Random random = Random.secure();
  final List<int> codeUnitsForVerifier = List.generate(32, (index) => random.nextInt(256));
  String codeVerifier = base64Url.encode(Uint8List.fromList(codeUnitsForVerifier));
  // codeVerifier = Uri.encodeComponent(codeVerifier);
  print('codeVerifier => $codeVerifier');
  print('----------------------------------------------------------------------');
  // 2. Generate code challenge
  final Uint8List codeUnitsForChallenge = Uint8List.fromList(utf8.encode(codeVerifier));
  final Digest digest = sha256.convert(codeUnitsForChallenge);
  String codeChallenge = base64Url.encode(digest.bytes);
  // codeChallenge = Uri.encodeComponent(codeChallenge);
  print('codeChallenge => $codeChallenge');
  print('----------------------------------------------------------------------');
  // 3. Generate Auth endpoint
  final String authorizationUrl = '$authorizationEndpoint?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&code_challenge=$codeChallenge&code_challenge_method=S256';
  print('authorizationUrl => $authorizationUrl');
  print('----------------------------------------------------------------------');
  // 4: Get the auth code by opening a WebView OR redirecting the user to the authorization URL
  // final dynamic tokenResponse = await doCallout(authorizationUrl, headers: {'Content-Type': 'application/x-www-form-urlencoded'});
  
  /*
  dynamic launchURLForCode() async {
    if (await canLaunchUrlString(authorizationUrl)) {
      dynamic responseStep4 = await launchUrl(Uri.parse(authorizationUrl));
      print('Response from step 3 => ${responseStep4.toString()}');
      return responseStep4;
    } else {
      print('Could not launch $authorizationUrl');
      return null;
    }
  }
  print('tokenResponse => ${tokenResponse.body.toString()}');
  final String authorizationCode = launchURLForCode();
  */
  
  // String url = 'http://localhost/?code=aPrx_yTkbIprMMh05N6wijq59eUAsGiVUinVDCxpJVJvMyg0KLaR.78nOIxBQ651PR7EEvEm1w%3D%3D';
  // Uri uri = Uri.parse(url);
  // String authorizationCode = uri.queryParameters['code'] ?? 'nai nai';
  // print('authorizationCode => $authorizationCode');
  // print('----------------------------------------------------------------------');

  // 5: Use this authorization code in request body to call the token endpoint, this is to get `token` from `code`
  // final Map<String, String> tokenRequestBody = {
  //   'grant_type': 'authorization_code',
  //   'client_id': clientId,
  //   'redirect_uri': redirectUri,
  //   'code': authorizationCode,
  //   'code_verifier': codeVerifier,
  // };


  // String cId = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  // String challenge = 'O5aQdbtiyQBZEUp43r_cHU9nyENCy6ioyKoEgjcSgsU%3D';
  // String verif = 'vtyJT1Ql06JQL2Y34RydX9C7ks98If-EL3mX_gIalBk%3D';
  // String authCode = 'aPrx_yTkbIprMMh05N6wijq59eUAsGiVUinVDCxpJVJvMyg0KLaR.78nOIxBQ651PR7EEvEm1w==';
  // String tePoint = 'https://login.salesforce.com/services/oauth2/token';

  // final String tokenAuthorizationUrl = '$tePoint?' + 
  // 'grant_type=authorization_code&' +
  // 'client_id=$cId&' +
  // 'redirect_uri=$redirectUri&' + 
  // 'code=$authCode&' +
  // 'code_verifier=$verif';

  // print('tokenAuthorizationUrl => $tokenAuthorizationUrl');
  // print('----------------------------------------------------------------------');

  // // 6: Call token endpoint to get auth token
  // final dynamic authTokenResponse = await http.post(Uri.parse(tokenAuthorizationUrl), headers: {'Content-Type': 'application/json'});
  // print('authTokenResponse Body => ${authTokenResponse.body})');
  // print('----------------------------------------------------------------------');

//   // 7. Use auth token further
//   print('AuthToken=> ${json.decode(authTokenResponse.body)})');
// }


















// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import 'package:crypto/crypto.dart';

// void main(){

//   Logger log = Logger();

//   print('Logging...');

//   // SF constant endpoints
//   String authorizationEndpoint = 'https://login.salesforce.com/services/oauth2/authorize';
//   String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
  
//   // SF instant specific constatns
//   const String clientId = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
//   const String redirectUri = 'your_redirect_uri';

//   // 1. Generate code verifier
//   Random random = Random.secure();
//   final List<int> codeUnitsForVerifier = List.generate(32, (index) { return random.nextInt(256); });
//   String codeVerifier =  base64Url.encode(Uint8List.fromList(codeUnitsForVerifier));
//   print('codeVerifier => $codeVerifier');

//   // 2. Generate code challenge
//   List<int> codeUnitsForChallenge = utf8.encode(codeVerifier);
//   Digest digest = sha256.convert(Uint8List.fromList(codeUnitsForChallenge));
//   List<int> bytes = digest.bytes;
//   String codeChallenge = base64Url.encode(bytes);
//   print('codeChallenge => $codeChallenge');

//   // 3. Generate Auth endpoint
//   String authorizationUrl = '''$authorizationEndpoint?
//                                 response_type=code&
//                                 client_id=$clientId&
//                                 redirect_uri=$redirectUri&      // new
//                                 code_challenge=$codeChallenge&  // new
//                                 code_challenge_method=S256      // new
//                                 ''';
//   print('authorizationUrl => $authorizationUrl');

//   // 4: Get the auth code by opening a WebView OR redirecting the user to the authorization URL
//   Future<dynamic> doCallout() async{
//     return await http.post(Uri.parse(authorizationUrl),headers: {'Content-Type': 'application/x-www-form-urlencoded'});
//   }
//   dynamic tokenResponse = doCallout();
//   String authorizationCode = tokenResponse.body['code'];
//   print('authorizationCode => $authorizationCode');

//   // 5: Use this authorization code in request body to call to token endpoint, this is to get `token` from `code`
//   // Token endpoint is already a constant url.
//   tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
//   Map<String, String> tokenRequestBody = {
//     'grant_type': 'authorization_code',
//     'client_id': clientId,
//     'redirect_uri': redirectUri,
//     'code': authorizationCode,      // new
//     'code_verifier': codeVerifier,  // new
//   };
//   print('tokenRequestBody => $tokenRequestBody');

//   // 6 : Call token endpoint to get auth token
//   dynamic requestBody = {};
//   Future<dynamic> doCallout2() async{
//     return await http.post(Uri.parse(authorizationUrl),headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: requestBody);
//   }
//   dynamic authTokenResponse = doCallout2();
//   print('authTokenResponse Body => ${authTokenResponse.body})');

//   // 7. Use auth token further
//   print('AuthToken=> ${json.decode(authTokenResponse.body)})');

}