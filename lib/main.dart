import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const latestTimestampKey = "latestTimestamp";
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> _createAlarm() async {
  print('zzzzzzzzzzzzzzzzzzzzzzzzz = _createAlarm');
  // Retrieve the latest timestamp from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? latestTimestamp = prefs.getString(latestTimestampKey);

  // Fetching data from API
  final response = await http.get(Uri.parse("https://tuimorsala.pythonanywhere.com/get_timestamp"));
  if (response.statusCode == 200) {
    print('zzzzzzzzzzzzzzzzzzzzzzzzz = 200');
    final Map<String, dynamic> data =  json.decode(response.body);
    final String timestamp = data['timestamp'];
    print('zzzzzzzzzzzzz timestamp zzzzz = $timestamp');
    print('zzzzzzzzzzzzz latestTimestamp zzzzzzzzzzzz = $latestTimestamp');
    // Checking if the timestamp has changed or not
    if (timestamp != latestTimestamp) {
      // saving the latest timestamp to shared preferences for next time
      latestTimestamp = timestamp;
      prefs.setString(latestTimestampKey, latestTimestamp);
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
        print("zzzzzzzzzzzzzzzzzzzzzzzzz = try catch end ");
      } 
      catch (e) {
        throw Exception('zzzzzzzzzzzzzzzzzzzzzzzz Error creating alarm: $e');
      }
    }
  } 
  else {
    throw Exception('zzzzzzzzzzzzzzzzzzzzzzzzz Failed to load data from API');
  }
}


Future<void> main() async {
  HttpOverrides.global = new PostHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  // Start the foreground service
  MyForegroundService().onStart();
  
  
  runApp(const MyApp());
}

void showPersistentNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // Change to your channel ID
    'Your Notification Title',
    importance: Importance.high,
    priority: Priority.high,
    ongoing: true, // This makes it persistent
    autoCancel: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    'CR ALARM',
    'Running CR Alarm ..... ',
    platformChannelSpecifics,
  );
}

Future<void> requestNotificationPermission(BuildContext context) async {
  final status = await Permission.notification.request();

  if (status.isGranted) {
    // Permission granted, you can show notifications now
    // You can call your notification creation method here
    showPersistentNotification();
  } else if (status.isDenied) {
    // Permission denied, show a dialog or message to inform the user
    // You can also provide a button to open app settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission'),
        content: const Text('Please allow notification access in app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Open app settings on button press
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, handle accordingly
    // You can inform the user and provide a way to open app settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission'),
        content: const Text('Notification permission is permanently denied. Please open app settings to enable it.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Open app settings on button press
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

// Function to request the permission
Future<void> requestScheduleExactAlarmPermission() async {
  PermissionStatus status = await Permission.scheduleExactAlarm.request();

  if (status.isGranted) {
    print('SCHEDULE_EXACT_ALARM permission granted');
  } else if (status.isDenied) {
    print('SCHEDULE_EXACT_ALARM permission denied');
    openAppSettings(); // Open app settings to allow the user to grant the permission
  } else if (status.isPermanentlyDenied) {
    print('SCHEDULE_EXACT_ALARM permission permanently denied');
    openAppSettings(); // Open app settings to allow the user to grant the permission
  }
}


class MyForegroundService {
  Future<void> onStart() async {
    print('zzzzzzzzzzzzzzzzzzzzzzzzz =  onStart');
    
    // Initialize your background tasks here.
    // For example, you can use Android Alarm Manager to schedule periodic tasks.
    await AndroidAlarmManager.periodic(
                          const Duration(seconds: 30), 4, _createAlarm,
                          exact: true,
                          wakeup: true,
                          allowWhileIdle: true,
                          rescheduleOnReboot: true,).then((val) => print('set up:$val'));
  }

  Future<void> onStop() async {
    // Clean up resources when the service is stopped.
    // For example, cancel scheduled alarms.
    print('zzzzzzzzzzzzzzzzzzzzzzzzz = stopped');
    await AndroidAlarmManager.cancel(4);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CR Alarm',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        dividerColor: Colors.grey,
        scaffoldBackgroundColor: const Color.fromARGB(255, 51, 98, 107),
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'CR Alarm Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AccessToken? _accessToken;
  List<Group> _groups = [];
  String? selectedGroupId;
  String? nextPageCursor;
  String? previousPageCursor;

  @override
  void initState() {
    super.initState();
    // requestPermissions();
    _checkFacebookLoginStatus();

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    // showPersistentNotification();
    requestNotificationPermission(context);
  }

  void fetchNextBatch() async {
    if (nextPageCursor == null) {
      return;
    }
    await _fetchUserGroupsBatch(_accessToken!.token, nextPageCursor , 1);
  }

  void fetchPreviousBatch() async {
    if (previousPageCursor == null) {
      return;
    }
    await _fetchUserGroupsBatch(_accessToken!.token, previousPageCursor, 2);
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

  // Future<void> requestPermissions() async {
  //   PermissionStatus status = await Permission.ignoreBatteryOptimizations.status;
  //   if (!status.isGranted) {
  //     status = await Permission.ignoreBatteryOptimizations.request();
  //   }
  // }

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
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('CR Alarm Student App'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              ElevatedButton(
                child: const Text("Show Persistent Notification"),
                onPressed: () {
                  showPersistentNotification();
                }
              ),
              ElevatedButton(
                child: const Text("Disable all Optimizations"),
                onPressed: () {
                  DisableBatteryOptimization.showDisableAllOptimizationsSettings('App Process', 'Enable App Battery Usage', 'Battery Optimization', 'Enable process');
                }
              ),
              ElevatedButton(
                child: const Text("request ScheduleExact Alarm Permission"),
                onPressed: () {
                  requestScheduleExactAlarmPermission();
                }
              ),
              ElevatedButton(
                child: const Text("Enable Auto Start"),
                onPressed: () {
                  DisableBatteryOptimization.showEnableAutoStartSettings(
                      "Enable Auto Start",
                      "Follow the steps and enable the auto start of this app");
                }
              ),
              ElevatedButton(
                child: const Text("Disable Battery Optimizations"),
                onPressed: () {
                  DisableBatteryOptimization
                      .showDisableBatteryOptimizationSettings();
                }
              ),
              ElevatedButton(
                child: const Text("Disable Manufacturer Battery Optimizations"),
                onPressed: () {
                  DisableBatteryOptimization
                      .showDisableManufacturerBatteryOptimizationSettings(
                          "Your device has additional battery optimization",
                          "Follow the steps and disable the optimizations to allow smooth functioning of this app");
                }
              ),
            // if (_accessToken == null)
            //   ElevatedButton(
            //     onPressed: (() {}),
            //     // onPressed: _loginWithFacebook,
            //     child: const Text('Login with Facebook'),
            //   ),
            if (_accessToken != null)
              const Column(
                children: [
                  Text(
                    'Select a Group from below dropdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
            if (selectedGroupId != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: fetchPreviousBatch,
                    child: const Text('Fetch Previous'),
                  ),
                  const SizedBox(width: 16), // Add spacing between buttons
                  ElevatedButton(
                    onPressed: fetchNextBatch,
                    child: const Text('Fetch Next'),
                  ),
                ],
              ),
            if (selectedGroupId != null)
              ElevatedButton(
                onPressed: () async {
                  // Set a repeating alarm with the selected group ID as a parameter
                  await AndroidAlarmManager.periodic(
                          const Duration(minutes: 5), 4, _createAlarm,
                          exact: true,
                          wakeup: true,
                          allowWhileIdle: true,
                          rescheduleOnReboot: true,
                          // Pass the selected group ID as a parameter
                          params: {'selectedGroupId': selectedGroupId})
                      .then((val) => print('set up:$val'));
                },
                child: const Text('Start CR Alarm with FB'),
              ),

            ElevatedButton(
              child: const Text('Start CR Alarm without FB'),
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.question,
                  borderSide: const BorderSide(
                    color: Colors.greenAccent,
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
                  title: 'Start Alarm?',
                  desc:
                      'It will start CR alarm. Make sure you have always internet connection.',
                  showCloseIcon: false,
                  btnCancelOnPress: () {},
                  // btnOkOnPress: () async {
                  //   // Set a repeating alarm with the selected group ID as a parameter
                  //   await AndroidAlarmManager.periodic(
                  //           const Duration(minutes: 5), 4, _createAlarm,
                  //           exact: true,
                  //           wakeup: true,
                  //           allowWhileIdle: true,
                  //           rescheduleOnReboot: true)
                  //       .then((val) => print('set up:$val'));
                  // },
                  buttonsTextStyle: const TextStyle(color: Colors.black),
                  reverseBtnOrder: true,
                ).show();
              },
            ),
            const SizedBox(height: 20),
            // if (selectedGroupId != null)
            ElevatedButton(
              child: const Text('Cancel Alarm'),
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
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
                  title: 'Cancel Sure?',
                  desc: 'Press OK button to cancel all the alarm.',
                  showCloseIcon: false,
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    // cancel();
                    MyForegroundService().onStop();
                  },
                  buttonsTextStyle: const TextStyle(color: Colors.black),
                  reverseBtnOrder: true,
                ).show();
              },
            ),
          ],
        ),
      ),
    );
    ;
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