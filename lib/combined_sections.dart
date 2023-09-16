import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'logger_section.dart';
import 'permissions_section.dart';
import 'create_alarm.dart';
import 'facebook_section.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';


class CombinedSections extends StatefulWidget {
  const CombinedSections({super.key});

  @override
  _CombinedSectionsState createState() => _CombinedSectionsState();
}

class _CombinedSectionsState extends State<CombinedSections> {

  Future<void> cancel() async {
    FlutterLogs.logInfo("combined_sections", "Cancel", "Canceled CR Alarm");
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
    FlutterLogs.logInfo("combined_sections", "displayPopUpAndroidAlarmManager", "Setting up AndroidAlarmManager, value = $value");
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
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const PermissionSection(),
            const SizedBox(height: 20),
            const FacebookSection(),
            const SizedBox(height: 20),
            const Text(
              'Alarm Section without FB',
              style: TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 5),
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
                  desc: 'It will start CR alarm. Make sure you have always internet connection.',
                  showCloseIcon: false,
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {
                    // Set a repeating alarm with the selected group ID as a parameter
                    await AndroidAlarmManager.periodic(const Duration(seconds: 10), 4, createAlarm, exact: true, wakeup: true, allowWhileIdle: true, rescheduleOnReboot: true)
                        .then((val) => displayPopUpAndroidAlarmManager(val));
                  },
                  buttonsTextStyle: const TextStyle(color: Colors.black),
                  reverseBtnOrder: true,
                ).show();
              },
            ),
            const SizedBox(height: 5),
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
            const SizedBox(height: 20),
            const LoggerSection(),
          ],
        ),
      ),
    );
  }
}
