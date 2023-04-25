import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:platform/platform.dart';


const simplePeriodicTask = "simplePeriodicTask";
const latestTimestampKey = "latestTimestamp";

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await _createAlarm();
    // Return true when the task is completed successfully
    return Future.value(true);
  });
}

class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

Future<void> _createAlarm() async {
  // Retrieve the latest timestamp from shared preferences
  final prefs = await SharedPreferences.getInstance();
  String? latestTimestamp = prefs.getString(latestTimestampKey);
  // Fetching data from API
  final response = await http.get(Uri.parse("https://web-production-5866.up.railway.app/latest_tweet"));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data =  json.decode(response.body);
    final String timestamp = data['timestamp'];
    const int timeZoneDifferenceInHours = 6;
    // Checking if the timestamp has changed or not
    if (timestamp != latestTimestamp) {
      // saving the latest timestamp to shared preferences for next time
      latestTimestamp = timestamp;
      prefs.setString(latestTimestampKey, latestTimestamp);
      // setting the alarm 1 minute after the fetching data
      // means when the app fetches the data, it will create the alarm 1 minute after that
      final DateTime scheduleddatetimeNow = DateTime.now();
      final DateTime scheduleddatetimeNowNow = scheduleddatetimeNow.add(const Duration(minutes: 1));
      int hour = scheduleddatetimeNowNow.hour;
      int minute = scheduleddatetimeNowNow.minute;
      int hh = hour;
      int mm = minute;
      
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: <String, dynamic>{
            'android.intent.extra.alarm.HOUR': hh,
            'android.intent.extra.alarm.MINUTES': mm,
            'android.intent.extra.alarm.SKIP_UI': true,
            'android.intent.extra.alarm.MESSAGE': 'CR Posted',
          },
        );
        intent.launch();
      } 
      catch (e) {
        print('Error creating alarm: callbackDispatcher= $e');
      }
    }
    else {
      print("\ntimestamp === latestTimestamp\n");
    }
  } 
  else {
    throw Exception('Failed to load data from API');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new PostHttpOverrides();
  Workmanager().initialize(callbackDispatcher);
  // Registering periodic task for every 15 minutes
  Workmanager().registerPeriodicTask(simplePeriodicTask , simplePeriodicTask,
        frequency: const Duration(minutes: 15));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CR Post Alarm App'),
        ),
        body: const Center(
          child: Text("Relax & Sleep - Don't have to miss any post from CR"),
        ),
      ),
    );
  }
}
