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
Future<void> _createAlarm(int id, Map<String, dynamic> params) async {
  print("xxxxxxxxxxxxxxxxxxxxxxxxx   _createAlarm");
  print(DateTime.now());

  // Retrieve the latest timestamp from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.reload();  // The magic line 
  String? latestTimestamp = prefs.getString(latestTimestampKey);
  print("xxxxxxxxxxxxxxxxxxxxxxxxx   latestTimestamp: $latestTimestamp");

  // Retrieve the selected group ID from the params map
  String selectedGroupId = params['selectedGroupId'];
  print("xxxxxxxxxxxxxxxxxxxxxxxxx   selectedGroupId: $selectedGroupId");

  // Retrieve the selected group ID from shared preferences
  // final SharedPreferences prefs2 = await SharedPreferences.getInstance();
  // await prefs2.reload();  // The magic line 
  // String? selectedGroupId = prefs2.getString(selectedGroupIdKey);
  // print("xxxxxxxxxxxxxxxxxxxxxxxxx   selectedGroupId: $selectedGroupId");
  // bool CheckValue = prefs.containsKey(selectedGroupIdKey);
  // if (selectedGroupId == null) {
  //   // if selectedGroupId is null, don't make api call and create the alarm
  //   return;
  // }

  // Fetching data from API
  final response = await http.get(Uri.parse("https://fb-grp-api.vercel.app/latest_post/$selectedGroupId"));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data =  json.decode(response.body);
    final String timestamp = data['timestamp'];
    // Checking if the timestamp has changed or not
    if (timestamp != latestTimestamp) {
      // saving the latest timestamp to shared preferences for next time
      latestTimestamp = timestamp;
      // prefs.reload();  // The magic line 
      prefs.setString(latestTimestampKey, latestTimestamp);
      // setting the alarm 1 minute after the fetching data
      // means when the app fetches the data, it will create the alarm 1 minute after that
      final DateTime scheduleddatetimeNow = DateTime.now();
      final DateTime scheduleddatetimeNowNow = scheduleddatetimeNow.add(const Duration(minutes: 2));
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
  // await AndroidAlarmManager.periodic(const Duration(minutes: 1), 4, _createAlarm,
  //     exact: true,
  //     wakeup: true,
  //     allowWhileIdle: true,
  //     rescheduleOnReboot: true,
  //     // Pass the selected group ID as a parameter
  //     params: {'selectedGroupId': selectedGroupId}).then((val) => print('set up:$val'));

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

  // void startAlarm() {
  //   print("xxxxxxxxxxxxxxxxxxxxxxxxx   startAlarm");
  //   AndroidAlarmManager.periodic(const Duration(minutes: 1), 4, _createAlarm,
  //     exact: true,
  //     wakeup: true,
  //     allowWhileIdle: true,
  //     rescheduleOnReboot: true);
  //   print("xxxxxxxxxxxxxxxxxxxxxxxxx   endAlarm");
  // }

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


  // Fetch user groups using Facebook Graph API
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

  // Save selected group ID to shared preferences
  // Future<void> _saveGroupId() async {
  //   // SharedPreferences prefs2 = await SharedPreferences.getInstance();
  //   // prefs2.reload();  // The magic line 
  //   // prefs2.setString(selectedGroupIdKey, selectedGroupId!);
  //   print("xxxxxxxxxxxxxxxxxx  _saveGroupId: $selectedGroupId");
  //   print(DateTime.now());
  // }

  Future<void> cancel() async {
    await AndroidAlarmManager.cancel(4);
    print("canceled");
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
                ElevatedButton(
                  onPressed: cancel,
                  child: Text('Cancel the alarm'),
                ),
              if (_accessToken == null)
                ElevatedButton(
                  onPressed: _loginWithFacebook,
                  child: Text('Login with Facebook'),
                ),
                // DropdownButton<String>(
                //   isDense: true,
                //   value: selectedGroupId,
                //   items: const [
                //     DropdownMenuItem<String>(
                //       value: '803298074774822',
                //       child: Text('803298074774822'),
                //     ),
                //     DropdownMenuItem<String>(
                //       value: '3511424965737970',
                //       child: Text('3511424965737970'),
                //     ),
                //   ],
                //   onChanged: (value) {
                //     setState(() {
                //       selectedGroupId = value;
                //     });
                //   },
                // ),
                // ElevatedButton(
                //   onPressed: () async {
                //     final prefs = await SharedPreferences.getInstance();
                //     prefs.setString(selectedGroupIdKey, selectedGroupId!);
                //     print("xxxxxxxxxxxxxxxxxxxxxxxxx   selectedGroupId: $selectedGroupId");

                //     // Set a repeating alarm with the selected group ID as a parameter
                //     await AndroidAlarmManager.periodic(const Duration(minutes: 1), 4, _createAlarm,
                //       exact: true,
                //       wakeup: true,
                //       allowWhileIdle: true,
                //       rescheduleOnReboot: true,
                //       // Pass the selected group ID as a parameter
                //       params: {'selectedGroupId': selectedGroupId}).then((val) => print('set up:$val'));
                //   },
                //   child: const Text('Save the Group for Alarm'),
                // ),
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
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString(selectedGroupIdKey, selectedGroupId!);
                    print("xxxxxxxxxxxxxxxxxxxxxxxxx   selectedGroupId: $selectedGroupId");

                    // Set a repeating alarm with the selected group ID as a parameter
                    await AndroidAlarmManager.periodic(const Duration(minutes: 1), 4, _createAlarm,
                      exact: true,
                      wakeup: true,
                      allowWhileIdle: true,
                      rescheduleOnReboot: true,
                      // Pass the selected group ID as a parameter
                      params: {'selectedGroupId': selectedGroupId}).then((val) => print('set up:$val'));
                  },
                  child: const Text('Save the Group for Alarm'),
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