// ignore_for_file: unused_import

import 'dart:io';
import 'dart:math';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';


const latestTimestampKey = "latestTimestamp";

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> createAlarm() async {
  print('zzzzzzzzzzzzzzzzzzzzzzzzz = _createAlarm');
  FlutterLogs.logInfo("create_alarm", "starting task", "it is inside the function");

  // Retrieve the latest timestamp from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? latestTimestamp = prefs.getString(latestTimestampKey);
  FlutterLogs.logInfo("create_alarm", "latestTimestamp = $latestTimestamp", "Retrieved latestTimestamp from shared preferences");

  // Fetching data from API
  final response = await http.get(Uri.parse("https://tuimorsala.pythonanywhere.com/get_timestamp"));
  FlutterLogs.logInfo("create_alarm", "API", "Fetched data from API don't know success or not");

  if (response.statusCode == 200) {
    print('zzzzzzzzzzzzzzzzzzzzzzzzz = 200');
    FlutterLogs.logInfo("create_alarm", "response.statusCode = 200", "Fetched data from API success");
    final Map<String, dynamic> data = json.decode(response.body);
    final String timestamp = data['timestamp'];

    print('zzzzzzzzzzzzz timestamp zzzzz = $timestamp');
    print('zzzzzzzzzzzzz latestTimestamp zzzzzzzzzzzz = $latestTimestamp');
    // Checking if the timestamp has changed or not
    if (timestamp != latestTimestamp) {
      FlutterLogs.logInfo("create_alarm", "timestamp != latestTimestamp", "timestamp has changed");
      // saving the latest timestamp to shared preferences for next time
      latestTimestamp = timestamp;
      prefs.setString(latestTimestampKey, latestTimestamp);
      FlutterLogs.logInfo("create_alarm", "latestTimestamp = $latestTimestamp", "saved latestTimestamp to shared preferences");
      // setting the alarm 1 minute after the fetching data
      // means when the app fetches the data, it will create the alarm 1 minute after that
      final DateTime scheduleddatetimeNow = DateTime.now();
      final DateTime scheduleddatetimeNowNow = scheduleddatetimeNow.add(const Duration(minutes: 2));
      int hour = scheduleddatetimeNowNow.hour;
      int minute = scheduleddatetimeNowNow.minute;
      int hh = hour;
      int mm = minute;
      print('zzzzzzzzzzzzzzzzzzzzzzzzz = $hh');
      print('zzzzzzzzzzzzzzzzzzzzzzzzz = $mm');
      try {
        FlutterLogs.logInfo("create_alarm", "try catch begin", "Creating alarm");
        print("zzzzzzzzzzzzzzzzzzzzzzzzz = try catch begin ");
        final intent = AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: <String, dynamic>{
            'android.intent.extra.alarm.HOUR': hh,
            'android.intent.extra.alarm.MINUTES': mm,
            'android.intent.extra.alarm.SKIP_UI': true,
            'android.intent.extra.alarm.MESSAGE': 'CR Posted',
          },
        );
        await intent.launch();
        FlutterLogs.logInfo("create_alarm", "try catch end", "Alarm created");
        print("zzzzzzzzzzzzzzzzzzzzzzzzz = try catch end ");
      } catch (e) {
        FlutterLogs.logInfo("create_alarm", "try catch error", "Error creating alarm: $e");
        throw Exception('zzzzzzzzzzzzzzzzzzzzzzzz Error creating alarm: $e');
      }
    }
    FlutterLogs.logInfo("create_alarm", "timestamp == latestTimestamp", "timestamp has not changed");
  } else {
    FlutterLogs.logInfo("create_alarm", "response.statusCode != 200", "Failed to load data from API");
    throw Exception('zzzzzzzzzzzzzzzzzzzzzzzzz Failed to load data from API');
  }
}
