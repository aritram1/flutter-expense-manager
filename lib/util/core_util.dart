// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'dart:math';

class CoreUtil {

  /////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////Generate a Random number//////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  int generateRandomNumber(){
    return Random().nextInt(99999999);
  }
  //////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////Testing of GET Request/////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  String _responseText = '';
  Future<String> getData(int postId) async {
    String apiUrl = 'https://jsonplaceholder.typicode.com/posts/$postId';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) { 
      final Map<String, dynamic> data = json.decode(response.body);
      _responseText = data.toString();
    } else {
      _responseText = 'Failed to load data from the API';      
    }
    return _responseText;
  }
}