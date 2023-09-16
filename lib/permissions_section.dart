import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class PermissionSection extends StatefulWidget {
  const PermissionSection({super.key});

  @override
  _PermissionSectionState createState() => _PermissionSectionState();
}

class _PermissionSectionState extends State<PermissionSection> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> requestAutoStartPermission(BuildContext context) async {
    DisableBatteryOptimization.showEnableAutoStartSettings("Enable Auto Start", "Follow the steps and enable the auto start of this app");
    bool? isAutoStartEnabled = await (DisableBatteryOptimization.isAutoStartEnabled);
    FlutterLogs.logInfo("permissions_section", "requestAutoStartPermission", "Requesting AutoStart Permission");
    if (true == isAutoStartEnabled) {
      FlutterLogs.logInfo("permissions_section", "requestAutoStartPermission", "AutoStart Permission Granted");
      print("Auto Start Permission granted");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'Auto Start Permission granted',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    } else {
      DisableBatteryOptimization.showEnableAutoStartSettings("Enable Auto Start", "Follow the steps and enable the auto start of this app");
    }
  }

  Future<void> requestBatteryOptimizationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.ignoreBatteryOptimizations.request();
    FlutterLogs.logInfo("permissions_section", "requestBatteryOptimizationPermission", "Requesting Battery Optimization Permission");
    if (status.isGranted) {
      FlutterLogs.logInfo("permissions_section", "requestBatteryOptimizationPermission", "BatteryOptimization Permission Granted");
      print("Battery Optimization Permission granted");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'Battery Optimization Permission granted',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    } else {
      status = await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> requestScheduleExactAlarmPermission(BuildContext context) async {
    PermissionStatus status = await Permission.scheduleExactAlarm.request();
    FlutterLogs.logInfo("permissions_section", "requestScheduleExactAlarmPermission", "Requesting ScheduleExactAlarm Permission");
    if (status.isGranted) {
      FlutterLogs.logInfo("permissions_section", "requestScheduleExactAlarmPermission", "ScheduleExactAlarm Permission Granted");
      print("Schedule Exact Alarm Permission granted");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'Schedule Exact Alarm Permission granted',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    } else {
      status = await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> requestSystemAlertWindowPermission(BuildContext context) async {
    PermissionStatus status = await Permission.systemAlertWindow.request();
    FlutterLogs.logInfo("permissions_section", "requestSystemAlertWindowPermission", "Requesting SystemAlertWindow Permission");
    if (status.isGranted) {
      FlutterLogs.logInfo("permissions_section", "requestSystemAlertWindowPermission", "SystemAlertWindow Permission Granted");
      print("System Alert Window Permission granted");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'System Alert Window Permission granted',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    } else {
      status = await Permission.systemAlertWindow.request();
    }
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.notification.request();
    FlutterLogs.logInfo("permissions_section", "requestNotificationPermission", "Requesting Notification Permission");
    if (status.isGranted) {
      FlutterLogs.logInfo("permissions_section", "requestNotificationPermission", "Notification Permission Granted");
      print("Notification Permission granted");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'Notification Permission granted',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    } else {
      status = await Permission.notification.request();
    }
  }

  void showPersistentNotification() async {
    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // Change to your channel ID
      'Your Notification Title',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // This makes it persistent
      autoCancel: false,
      visibility: NotificationVisibility.public,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'CR ALARM',
      'Running CR Alarm ..... ',
      platformChannelSpecifics,
    );
    FlutterLogs.logInfo("permissions_section", "showPersistentNotification", "Persistent Notification showed");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Permission Section',
              style: TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
                child: const Text("All Battery Optimizations"),
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
                    title: 'Disable All Battery Optimizations?',
                    desc: 'It will disable the battery optimization and allow smooth functioning of this app',
                    showCloseIcon: false,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      requestBatteryOptimizationPermission(context);
                    },
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    reverseBtnOrder: true,
                  ).show();
                }),
            const SizedBox(height: 5),
            ElevatedButton(
                child: const Text("Schedule Exact Alarm"),
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
                    title: 'Request Schedule Exact Alarm Permission?',
                    desc: 'It will allow you to schedule an alarm at a specific time',
                    showCloseIcon: false,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      requestScheduleExactAlarmPermission(context);
                    },
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    reverseBtnOrder: true,
                  ).show();
                }),
            const SizedBox(height: 5),
            ElevatedButton(
                child: const Text("Auto Start"),
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
                    title: 'Enable Auto Start Permission?',
                    desc: 'It will enable the auto start of this app when the device is restarted',
                    showCloseIcon: false,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      requestAutoStartPermission(context);
                    },
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    reverseBtnOrder: true,
                  ).show();
                }),
            const SizedBox(height: 5),
            ElevatedButton(
                child: const Text("System Alert Window"),
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
                    title: 'Enable System Alert Window Permission?',
                    desc: 'It will take you to the settings to enable the system alert window',
                    showCloseIcon: false,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      requestSystemAlertWindowPermission(context);
                    },
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    reverseBtnOrder: true,
                  ).show();
                }),
            const SizedBox(height: 5),
            ElevatedButton(
                child: const Text("Notification"),
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
                    title: 'Enable Notification Permission?',
                    desc: 'It will take you to the settings to enable the notification permission',
                    showCloseIcon: false,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      requestNotificationPermission(context);
                    },
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    reverseBtnOrder: true,
                  ).show();
                }),
            const SizedBox(height: 5),
            ElevatedButton(
                child: const Text("Show Persistent Notification"),
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
                    title: 'Enable Persistent Notification?',
                    desc: 'It will show a persistent notification in the status bar',
                    showCloseIcon: false,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      showPersistentNotification();
                    },
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    reverseBtnOrder: true,
                  ).show();
                }),
          ],
        ),
      ),
    );
  }
}
