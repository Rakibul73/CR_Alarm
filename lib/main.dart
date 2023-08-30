import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
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

class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> _createAlarm(int id, Map<String, dynamic> params) async {
  // Retrieve the latest timestamp from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.reload();  // The magic line 
  String? latestTimestamp = prefs.getString(latestTimestampKey);

  // Retrieve the selected group ID from the params map
  String selectedGroupId = params['selectedGroupId'];

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
  // runApp(MyApp());
  runApp(MaterialApp(
    home: MyApp(),
  ));
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
  // int batchStart = 0;
  String? nextPageCursor;
  String? previousPageCursor;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _checkFacebookLoginStatus();
  }

  void fetchNextBatch() async {
    if (nextPageCursor == null) {
      print("nextPageCursor is ===== $nextPageCursor");
      return;
    }
    print("zzzzzzzzzzzzzzzzz is ===== $nextPageCursor");
    await _fetchUserGroupsBatch(_accessToken!.token, nextPageCursor , 1);
  }

  void fetchPreviousBatch() async {
    if (previousPageCursor == null) {
      print("previousPageCursor is ===== $previousPageCursor");
      return;
    }
    print("zzzzzzzzzzzzzzzzz is ===== $previousPageCursor");
    await _fetchUserGroupsBatch(_accessToken!.token, previousPageCursor , 2);
  }

  Future<void> _fetchUserGroupsBatch(String accessToken, String? pageCursor , int zz) async {
    String url = 'https://graph.facebook.com/v17.0/me/groups';
    if (pageCursor != null && zz == 1) {
      url += '?after=$pageCursor';
    }
    if (pageCursor != null && zz == 2) {
      url += '?before=$pageCursor';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final groups = List<Group>.from(
        data['data'].map((group) => Group.fromJson(group)),
      );
      nextPageCursor = data['paging']['cursors']['after'];
      previousPageCursor = data['paging']['cursors']['before'];

      setState(() {
        _groups = groups;
        selectedGroupId = null; // Reset selected group
      });
    } else {
      throw Exception('Failed to fetch groups');
    }
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
      nextPageCursor = data['paging']['cursors']['after'];
      previousPageCursor = data['paging']['cursors']['before'];
      setState(() {
        _groups = groups;
      });
    } else {
      throw Exception('Failed to fetch groups');
    }
  }

  Future<void> cancel() async {
    await AndroidAlarmManager.cancel(4);
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
              const SizedBox(height: 20),
              if (selectedGroupId != null)
                Column(
                  children: [
                    const Text(
                      'You selected: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Group ID: $selectedGroupId',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Group Name: ${_groups.firstWhere((group) => group.id == selectedGroupId).name}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text('Fetch Previous'),
                      onPressed: fetchPreviousBatch,
                    ),
                    SizedBox(width: 16), // Add spacing between buttons
                    ElevatedButton(
                      child: Text('Fetch Next'),
                      onPressed: fetchNextBatch,
                    ),
                  ],
                ),
              // if (selectedGroupId != null)
                ElevatedButton(
                  onPressed: () async {
                    // Set a repeating alarm with the selected group ID as a parameter
                    await AndroidAlarmManager.periodic(const Duration(minutes: 1), 4, _createAlarm,
                      exact: true,
                      wakeup: true,
                      allowWhileIdle: true,
                      rescheduleOnReboot: true,
                      // Pass the selected group ID as a parameter
                      params: {'selectedGroupId': selectedGroupId}).then((val) => print('set up:$val'));
                  },
                  child: Text('Start CR Alarm'),
                ),
              // if (selectedGroupId != null)
                ElevatedButton(
                  child: Text('Cancel Alarm'),
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                      width: 300,
                      buttonsBorderRadius: const BorderRadius.all(
                        Radius.circular(25),
                      ),
                      dismissOnTouchOutside: false,
                      dismissOnBackKeyPress: false,
                      headerAnimationLoop: true,
                      animType: AnimType.bottomSlide,
                      title: 'Cancel Alarm?',
                      desc: 'Press OK button to cancel all the fb group alarm.',
                      showCloseIcon: false,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {cancel();},
                      buttonsTextStyle: const TextStyle(color: Colors.black),
                      reverseBtnOrder: true,
                    ).show();
                  },
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

