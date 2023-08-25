import 'dart:io';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:platform/platform.dart';


const simplePeriodicTask = "simplePeriodicTask";
const latestTimestampKey = "latestTimestamp";
const selectedGroupIdKey = "selectedGroupId";


class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> _createAlarm() async {
  // Retrieve the latest timestamp from shared preferences
  final prefs = await SharedPreferences.getInstance();
  String? latestTimestamp = prefs.getString(latestTimestampKey);

  // Retrieve the selected group ID from shared preferences
  final selectedGroupId = prefs.getString(selectedGroupIdKey);
  if (selectedGroupId == null) {
    // Handle the case where selectedGroupId is null
    print("Selected group ID is null");
    return;
  }

  // Fetching data from API
  final response = await http.get(Uri.parse("https://fb-grp-api.vercel.app/latest_post/$selectedGroupId"));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data =  json.decode(response.body);
    final String timestamp = data['timestamp'];
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
        await intent.launch();
      } 
      catch (e) {
        throw Exception('Error creating alarm: $e');
      }
    }
  } 
  else {
    throw Exception('Failed to load data from API');
  }
}



Future<void> main() async {
  HttpOverrides.global = new PostHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(const Duration(seconds: 30), 4, _createAlarm,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AccessToken? _accessToken;
  List<Group> _groups = [];
  String? selectedGroupId;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _checkFacebookLoginStatus();
  }

  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      status = await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> _checkFacebookLoginStatus() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _accessToken = accessToken;
    });

    if (accessToken != null) {
      await _fetchUserGroups(accessToken.token);
    }
  }

  Future<void> _fetchUserGroups(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://graph.facebook.com/v17.0/me/groups'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final groups = List<Group>.from(
        data['data'].map((group) => Group.fromJson(group)),
      );
      setState(() {
        _groups = groups;
      });
    } else {
      throw Exception('Failed to fetch groups');
    }
  }

  Future<void> _saveGroupId() async {
    // Save selected group ID to shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(selectedGroupIdKey, selectedGroupId!);
    print("================xxxxxxxxxxxxxxxx================");
  }

  Future<void> _loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'user_posts', 'user_managed_groups', 'groups_show_list', 'publish_to_groups'],
      loginBehavior: LoginBehavior.dialogOnly, // (only android) show an authentication dialog instead of redirecting to facebook app
    );

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      setState(() {
        _accessToken = accessToken;
      });
      await _fetchUserGroups(accessToken.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CR Post Alarm App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_accessToken == null)
                ElevatedButton(
                  onPressed: _loginWithFacebook,
                  child: Text('Login with Facebook'),
                ),
              if (_accessToken != null)
                DropdownButton<String>(
                  isDense: true, // Add this line
                  value: selectedGroupId,
                  items: _groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group.id,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGroupId = value;
                    });
                  },
                ),

                
              
              if (selectedGroupId != null)
                ElevatedButton(
                  onPressed: _saveGroupId,
                  child: Text('Save the Group for Alarm'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
    );
  }
}