import 'dart:io';
// import 'dart:math';
import 'package:flutter_logs/flutter_logs.dart';
// import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:platform/platform.dart';
import 'combined_sections.dart';

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = new PostHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  //Initialize Logging
  await FlutterLogs.initLogs(
      logLevelsEnabled: [LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR, LogLevel.SEVERE],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ["device", "network", "errors"],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: "MyLogs",
      logsExportDirectoryName: "MyLogs/Exported",
      debugFileOperations: true,
      isDebuggable: true);
  runApp(const MyApp());
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('CR Alarm Student App'),
        ),
      ),
      body: const CombinedSections(),
    );
  }
}
