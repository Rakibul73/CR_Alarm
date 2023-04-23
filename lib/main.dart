import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';





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
      title: 'CR Post Alarm App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

Future<Map<String, dynamic>> fetchDataFromApi(String apiUrl) async {
  // Request internet permission
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
    // Schedule a periodic Timer to call _fetchApiAndSetAlarm every 1 minutes
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      _fetchApiAndSetAlarm();
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


      if (timestamp != _latestTimestamp) {
        // If the timestamp has changed, set the alarm
        _latestTimestamp = timestamp;

        final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        final DateTime dateInApiTimezone = dateFormat.parse(timestamp);
        final DateTime dateInLocalTime = dateInApiTimezone.add(Duration(hours: timeZoneDifferenceInHours));
        final DateTime scheduledDateTime = dateInLocalTime.add(const Duration(minutes: 2));


        int hour = scheduledDateTime.hour;
        int minute = scheduledDateTime.minute;


        // NotificationService.scheduleAlarm(scheduledDateTime);
        // Create an alarm at 23:59
        FlutterAlarmClock.createAlarm(hour, minute , title: "CR Posted" );
      }
    } catch (error) {
      _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Failed to set alarm: $error'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('CR Post Alarm App'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(children: <Widget>[
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // show alarm
                FlutterAlarmClock.showAlarms();
              },
              child: const Text(
                'Show Alarms',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
      ])),
    );
  }
}