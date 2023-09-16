import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';

class LoggerSection extends StatefulWidget {
  const LoggerSection({super.key});

  @override
  _LoggerSectionState createState() => _LoggerSectionState();
}

class _LoggerSectionState extends State<LoggerSection> {
  List<String> logFiles = [];
  var logStatus = '';

  @override
  void initState() {
    super.initState();
  }

  void printAllLogs() {
    FlutterLogs.printLogs(exportType: ExportType.ALL, decryptBeforeExporting: true);
    setLogsStatus(status: "All logs printed");
  }

  void setLogsStatus({String status = '', bool append = false}) {
    setState(() {
      logStatus = status;
    });
  }

  Future<void> _loadLogFiles() async {
    FlutterLogs.logInfo("logger_section", "_loadLogFiles", "trying to Load log files");
    try {
      Directory? appDirectory = await getExternalStorageDirectory();
      print('appDirectory = $appDirectory');

      if (appDirectory != null) {
        Directory logRootDirectory = Directory('${appDirectory.path}/MyLogs/Logs');
        print('logRootDirectory = $logRootDirectory');
        List<String> files = await _listLogFiles(logRootDirectory);

        setState(() {
          logFiles = files;
        });
      }
      FlutterLogs.logInfo("logger_section", "_loadLogFiles", "loaded all log files");
      print('logFiles = $logFiles');
    } catch (e) {
      FlutterLogs.logError("logger_section", "_loadLogFiles", "Error loading log files: $e");
      print('Error loading log files: $e');
    }
  }

  Future<List<String>> _listLogFiles(Directory directory) async {
    List<String> files = [];
    FlutterLogs.logInfo("logger_section", "_listLogFiles", "Listing log files from directory");
    try {
      // List all entries in the directory
      List<FileSystemEntity> entries = directory.listSync();

      for (var entry in entries) {
        if (entry is File && entry.path.endsWith('.log')) {
          // If it's a log file, add its path to the list
          files.add(entry.path);
        } else if (entry is Directory) {
          // If it's a directory, recursively list log files in it
          List<String> subdirectoryFiles = await _listLogFiles(entry);
          files.addAll(subdirectoryFiles);
        }
      }
      FlutterLogs.logInfo("logger_section", "_listLogFiles", "Loaded all log files");
    } catch (e) {
      FlutterLogs.logError("logger_section", "_listLogFiles", "Error listing log files from directory: $e");
      print('Error listing log files in directory: $e');
    }
    return files;
  }

  void _viewLogFile(String filePath) async {
    FlutterLogs.logInfo("logger_section", "_viewLogFile", "trying to view log file");
    try {
      File logFile = File(filePath);
      String content = await logFile.readAsString();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Log File Contents'),
            content: SingleChildScrollView(
              child: Text(content),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      FlutterLogs.logInfo("logger_section", "_viewLogFile", "successfully viewed log file");
    } catch (e) {
      FlutterLogs.logError("logger_section", "_viewLogFile", "Error reading log file: $e");
      print('Error reading log file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Logging Section',
              style: TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                printAllLogs();
              },
              child: const Text('print All Logs in terminal'),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                _loadLogFiles();
              },
              child: const Text('load Log Files from device with button'),
            ),
            const SizedBox(height: 5),
            Column(
              children: [
                for (String logFile in logFiles)
                  ElevatedButton(
                    onPressed: () {
                      _viewLogFile(logFile);
                    },
                    child: Text('View Log File ${logFiles.indexOf(logFile) + 1}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
