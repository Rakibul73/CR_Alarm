import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';





class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  HttpOverrides.global = new PostHttpOverrides();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
Future<Map<String, dynamic>> fetchDataFromApi(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load data from API');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  // Add this variable to store the latest timestamp
  String? _latestTimestamp;
  // Add this variable to store the Timer instance
  Timer? _timer;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _fetchApiAndSetAlarm(); // Call this function when the app starts
    // Schedule a periodic Timer to call _fetchApiAndSetAlarm every 15 minutes
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      // print("\n------repeting----up----\n");
      _fetchApiAndSetAlarm();
      // print("\n------repeting----Down----\n");
    });
  }

  @override
  void dispose() {
    // Cancel the Timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchApiAndSetAlarm() async {
    try {
      final Map<String, dynamic> data = await fetchDataFromApi('https://web-production-5866.up.railway.app/latest_tweet');
      final String timestamp = data['timestamp'];
      final String text = data['text'];
      // Replace this value with the actual time difference in hours
      const int timeZoneDifferenceInHours = 6; // Change this value according to your time difference

      // print("\n     Latest timestamp: $_latestTimestamp");
      // print("        New timestamp: $timestamp");

      if (timestamp != _latestTimestamp) {
        // If the timestamp has changed, set the alarm
        _latestTimestamp = timestamp;

        final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        final DateTime dateInApiTimezone = dateFormat.parse(timestamp);
        final DateTime dateInLocalTime = dateInApiTimezone.add(Duration(hours: timeZoneDifferenceInHours));
        final DateTime scheduledDateTime = dateInLocalTime.add(const Duration(minutes: 2));

        // print("\n        Alarm set to  =  ");
        // print(scheduledDateTime);
        // print("\nz=====@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@===z=z=z=z=z=zz=z=z=z=z=zz=z=z=z\n");

        NotificationService.scheduleAlarm(scheduledDateTime);
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content: Text('Alarm set for $text at ${scheduledDateTime.toString()}'),
        ));
      }
      // else {
      //   print("        Timestamp has not changed");
      // }
    } catch (error) {
      _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Failed to set alarm: $error'),
      ));
    }
  }

  Future<void> _setAlarmFromApi() async {
    try {
      final Map<String, dynamic> data = await fetchDataFromApi('https://web-production-5866.up.railway.app/latest_tweet');
      final String timestamp = data['timestamp'];
      final String text = data['text'];
      // Replace this value with the actual time difference in hours
      const int timeZoneDifferenceInHours = 6; // Change this value according to your time difference


      final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final DateTime dateInApiTimezone = dateFormat.parse(timestamp);
      final DateTime dateInLocalTime = dateInApiTimezone.add(Duration(hours: timeZoneDifferenceInHours));
      final DateTime scheduledDateTime = dateInLocalTime.add(const Duration(minutes: 2));

      // print("z========z=z=z=z=z=zz=z=z=z=z=zz=z=z=z\n");
      // print(scheduledDateTime);
      // print("\nz========z=z=z=z=z=zz=z=z=z=z=zz=z=z=z\n");

      NotificationService.scheduleAlarm(scheduledDateTime);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Alarm set for $text at ${scheduledDateTime.toString()}'),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to set alarm: $error'),
      ));
    }
  }




  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Alarm App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Time: ${_selectedTime.format(context)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Select Time'),
            ),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final scheduledDate = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                if (scheduledDate.isBefore(now)) {
                  // if the time has already passed, schedule for the next day
                  scheduledDate.add(const Duration(days: 1));
                }
                NotificationService.scheduleAlarm(scheduledDate);
              },
              child: const Text('Set Alarm'),
            ),
            ElevatedButton(
              onPressed: _setAlarmFromApi,
              child: const Text('Set Alarm from API'),
            ),

          ],
        ),
      ),
    );
  }
}