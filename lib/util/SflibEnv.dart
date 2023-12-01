import 'dart:core';

class SflibEnv {
  static const String CONST_LOGIN_ERROR = 'Failed to login to Salesforce';
  static const String CONST_SAVE_SMS_ERROR = 'Failed to save the data to Salesforce';
  static const String  String _baseUrl = 'https://login.salesforce.com/services/oauth2/token';
  final String _clientId = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  final String _clientSecret = '3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7'; 
  final String _userName = 'aritram1@gmail.com.financeplanner'; 
  final String _tokenGrantType = 'password'; 
  final String _pwdWithToken = 'financeplanner123W8oC4taee0H2GzxVbAqfVB14'; 
  final int CONST_DML_BATCH_SIZE = 200;
}