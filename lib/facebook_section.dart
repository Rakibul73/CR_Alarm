import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:http/http.dart' as http;
import 'create_alarm.dart';

class FacebookSection extends StatefulWidget {
  const FacebookSection({super.key});

  @override
  _FacebookSectionState createState() => _FacebookSectionState();
}

class _FacebookSectionState extends State<FacebookSection> {
  AccessToken? _accessToken;
  List<Group> _groups = [];
  String? selectedGroupId;
  String? nextPageCursor;
  String? previousPageCursor;

  @override
  void initState() {
    super.initState();
    _checkFacebookLoginStatus();
  }

  Future<void> cancel() async {
    FlutterLogs.logInfo("facebook_section", "Cancel", "Canceled CR Alarm");
    await AndroidAlarmManager.cancel(4);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      width: 300,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      title: 'Success',
      desc: 'CR Alarm Successfully Cancelled',
      dismissOnTouchOutside: true,
      autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
    ).show();
    print("Alarm Manager Cancelled");
  }

  void displayPopUpAndroidAlarmManager(bool value) async {
    print('set up:$value');
    FlutterLogs.logInfo("facebook_section", "displayPopUpAndroidAlarmManager", "Setting up AndroidAlarmManager, value = $value");
    if (value) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'CR Alarm Started',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        width: 300,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: 'Error',
        desc: 'CR Alarm didn\'t start',
        dismissOnTouchOutside: true,
        autoHide: const Duration(seconds: 3), // Auto hide after 3 seconds
      ).show();
    }
  }

  void fetchNextBatch() async {
    if (nextPageCursor == null) {
      FlutterLogs.logInfo("facebook_section", "fetchNextBatch", "No Next Page");
      return;
    }
    FlutterLogs.logInfo("facebook_section", "fetchNextBatch", "Fetching Next Page");
    await _fetchUserGroupsBatch(_accessToken!.token, nextPageCursor, 1);
  }

  void fetchPreviousBatch() async {
    if (previousPageCursor == null) {
      FlutterLogs.logInfo("facebook_section", "fetchPreviousBatch", "No Previous Page");
      return;
    }
    FlutterLogs.logInfo("facebook_section", "fetchPreviousBatch", "Fetching Previous Page");
    await _fetchUserGroupsBatch(_accessToken!.token, previousPageCursor, 2);
  }

  Future<void> _fetchUserGroupsBatch(String accessToken, String? pageCursor, int zz) async {
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
    FlutterLogs.logInfo("facebook_section", "_fetchUserGroupsBatch", "Fetched data from fb API");
    if (response.statusCode == 200) {
      FlutterLogs.logInfo("facebook_section", "_fetchUserGroupsBatch", "Fetched data from fb API success = 200");
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
      FlutterLogs.logInfo("facebook_section", "_fetchUserGroupsBatch", "Failed to fetch groups from fb API");
      throw Exception('Failed to fetch groups');
    }
  }

  Future<void> _checkFacebookLoginStatus() async {
    FlutterLogs.logInfo("facebook_section", "_checkFacebookLoginStatus", "Checking Facebook Login Status");
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _accessToken = accessToken;
    });
    if (accessToken != null) {
      FlutterLogs.logInfo("facebook_section", "_checkFacebookLoginStatus", "Facebook Login Successful");
      await _fetchUserGroups(accessToken.token);
    }
    FlutterLogs.logInfo("facebook_section", "_checkFacebookLoginStatus", "User is not logged in");
  }

  Future<void> _fetchUserGroups(String accessToken) async {
    FlutterLogs.logInfo("facebook_section", "_fetchUserGroups", "User Groups initial Fetching");
    final response = await http.get(
      Uri.parse('https://graph.facebook.com/v17.0/me/groups'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    FlutterLogs.logInfo("facebook_section", "_fetchUserGroups", "Fetched data from fb API");
    if (response.statusCode == 200) {
      FlutterLogs.logInfo("facebook_section", "_fetchUserGroups", "Fetched data from fb API success = 200");
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
      FlutterLogs.logInfo("facebook_section", "_fetchUserGroups", "Failed to fetch groups from fb API");
      throw Exception('Failed to fetch groups');
    }
  }

  Future<void> _loginWithFacebook() async {
    FlutterLogs.logInfo("facebook_section", "_loginWithFacebook", "User trying to Login with Facebook");
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'user_posts', 'user_managed_groups', 'groups_show_list', 'publish_to_groups'],
      loginBehavior: LoginBehavior.dialogOnly, // (only android) show an authentication dialog instead of redirecting to facebook app
    );
    if (result.status == LoginStatus.success) {
      FlutterLogs.logInfo("facebook_section", "_loginWithFacebook", "User logged in with Facebook");
      final AccessToken accessToken = result.accessToken!;
      setState(() {
        _accessToken = accessToken;
      });
      await _fetchUserGroups(accessToken.token);
    }
    FlutterLogs.logInfo("facebook_section", "_loginWithFacebook", "User fb login failed");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Facebook Alarm Section',
              style: TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 5),
            if (_accessToken == null)
              ElevatedButton(
                onPressed: _loginWithFacebook,
                child: const Text('Login with Facebook'),
              ),
            if (_accessToken != null)
              const Column(
                children: [
                  Text(
                    'Select a Group from below dropdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 5),
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
            const SizedBox(height: 5),
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
            const SizedBox(height: 5),
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
            const SizedBox(height: 5),
            if (selectedGroupId != null)
              ElevatedButton(
                onPressed: () async {
                  // Set a repeating alarm with the selected group ID as a parameter
                  await AndroidAlarmManager.periodic(const Duration(seconds: 15), 4, createAlarm,
                      exact: true,
                      wakeup: true,
                      allowWhileIdle: true,
                      rescheduleOnReboot: true,
                      // Pass the selected group ID as a parameter
                      params: {'selectedGroupId': selectedGroupId}).then((val) => displayPopUpAndroidAlarmManager(val));
                },
                child: const Text('Start CR Alarm with FB'),
              ),
            const SizedBox(height: 5),
            if (selectedGroupId != null)
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
                      cancel();
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
