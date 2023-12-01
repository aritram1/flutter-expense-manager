import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_phone_app/util/message_util.dart';
import 'package:flutter_phone_app/util/sflib.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'widget/messages_list_view.dart';

///////////////////////////////Main method to run////////////////////////////////////
void main() {
  runApp(const MyApp());
}

/////////////////////MyApp Stateless Parent Widget //////////////////////////////////
  
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 95, 54, 244),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SMS Forwarder'),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////Main stateful widget////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////  
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////Stateful Class//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////  
class _MyHomePageState extends State<MyHomePage> {
  
  final String CONST_DEFAULT_TEXT = 'Nothing to show. Tap the message button...';
  String _response = '';
  String _error = '';
  int _counter = 1;
  List<SmsMessage> _messages = [];
  String _sfLoginResponse = '';
  String _sfSaveResponse = '';
  String currentPage = ''; //Other options are 'Message', 'Login' and 'Save'
  String sender = '';
  int count = 0;

  //////////////////////Initialise the state from parent Class///////////////////////
  @override
  void initState() {
    super.initState();
  }
  //////////////////////Method to handle Salesforce Login////////////////////////////
  void handleLoginToSFButtonPress() async {
    final loginResponse = await Sflib.loginToSalesforce();
    setState(() {
      _sfLoginResponse = loginResponse;
      currentPage = 'Login';
    });
  }
  //////////////////////Method to save data to Salesforce////////////////////////////
  void handleSaveDataToSFButtonPress() async {
    final List<SmsMessage> msgs = await MessageUtil().getMessages('', 10);
    List<Map<String, dynamic>> data = [];
    String deviceName = androidInfo.model;
    for(SmsMessage msg in msgs){
      data.add({
        "FinPlan__content__c"    : msg.body,
        "FinPlan__Sender__c"     : msg.sender,
        "FinPlan_Received_at__c" : msg.date.toString()
        "FinPlan__Device__c": deviceName
        
      });
    }
    final saveDataResponse = await Sflib.insertSFData('FinPlan__SMS_Message__c', data);
    setState(() {
      _sfSaveResponse = saveDataResponse;
      currentPage = 'Save';
    });
  }
  //////////////////////Method to get SMS data///////////////////////////////////////
  void handleMessageButtonPress() async{
    final msgs = await MessageUtil().getMessages(sender, count);
    setState(() {
      _messages = msgs;
      currentPage = 'Message';
    });
  }

  //////////////////////Build Method for generating widget content///////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: () {
          if (currentPage == 'Message') {
            return MessagesListView(
              messages: _messages,
            );
          } 
          else if(currentPage == 'Login') {
            return Text(
              _sfLoginResponse,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            );
          }
          else if(currentPage == 'Save') {
            return Text(
              _sfSaveResponse,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            );
          }
          else{
            return Text(
              CONST_DEFAULT_TEXT,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            );
          }
        }(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child : FloatingActionButton(
              onPressed: handleMessageButtonPress,
              child: const Icon(Icons.message),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: handleLoginToSFButtonPress,
              child: const Icon(Icons.login),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: handleSaveDataToSFButtonPress,
              child: const Icon(Icons.save),
            ),
          )
        ],
        )
        
    );
  }
}

