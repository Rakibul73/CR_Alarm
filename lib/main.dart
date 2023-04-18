import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    NotificationService.init();
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
      appBar: AppBar(
        title: const Text('Alarm App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Time: ${_selectedTime.format(context)}',
              style: Theme.of(context).textTheme.headline5,
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
          ],
        ),
      ),
    );
  }
}