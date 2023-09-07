<div align="center">
  <h1>CR Alarm</h1>


> Autmatic alarm - based on latest tweet

[![](https://skillicons.dev/icons?i=flutter,dart,vscode,androidstudio)]()
</div>
<hr/>
The CR Alarm App is a Flutter-based Android app that auto set alarms based on the time of the latest post / tweet of a specific FB Group / Twitter user that fetches from api. When that specific user post in that group or tweets, it sets an alarm so that you don't miss that user's posts, even if you sleep.
<hr/>

## One usecase
Suppose In university, there is a CR (Class Representative) in your class. He posts the class schedule that he receives from the teachers in a Facebook group. However, you never know when he will post, and sometimes teachers may inform the CR of the class schedule 15 or 30 minutes in advance while you are fast asleep. Now imagine if there was an alarm clock app that would only sound when CR published a class schedule. You are no longer need to miss classes in the future. 


## Download latest version from [here](https://github.com/Rakibul73/CR_Alarm/releases/latest)
## Features

- [x] Auto sets alarm
- [x] Making a api backend & hosting
- [x] Auto fetching tweets/post from api
- [x] Adding Background service (App can be closed from recent tab)
- [x] Making a functional UI
- [x] Adding Facebook api support (only when FB Group is public)
- [x] Allow users the ability to select which group posts they want to follow.
- [ ] Allow users the ability to select whose tweets they want to follow.
- [ ] Android SDK Platform Support
    - [x] Currently supported: `Android 9 (API level 28) and below`
    - [ ] Not supported: `Android 10 (API level 29) and above` cause only problem is `android.intent.action.SET_ALARM` action from `Android Intent Plus` plugin is `only executing` when the app is in the screen, it is `not executing` when the app is in recent tabs or closed or in background.




## Installation

* You should have properly installed `flutter` & `Emuletor` in your machine.
* Clone the repository to your local machine.
* Run this in terminal to install the required packages.
```bash
flutter packages get
```
* Run the app using
```bash
flutter run
```

<hr>

### if below error come from api calling

```bash
HandshakeException: Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED: certificate has expired(handshake.cc:393))
```
Then use this video 
https://youtu.be/aaXMUM-_4lQ

or

Step 1:
In your main.dart file, add or import the following class:
```bash
class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
```
Step 2:
Add the following line after function definition In your main function:
```bash
HttpOverrides.global = new PostHttpOverrides();
```
Example :
```bash
import 'dart:io';
 
 
import 'package:flutter/material.dart';
import 'package:point/routes.dart';
import 'package:point/theme.dart';
 
import 'login/LoginScreen.dart';
 
class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient( context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
 
void main() {
  HttpOverrides.global = new PostHttpOverrides();
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme(),
      // home: SplashScreen(),
      // We use routeName so that we dont need to remember the name
      initialRoute: LoginScreen.routeName,
      routes: routes,
    );
  }
}
```

<hr>
## Acknowledgements

- [Android Intent Plus](https://pub.dev/packages/android_intent_plus) library for alarm
- removed ~~[Flutter Alarm Clock](https://pub.dev/packages/flutter_alarm_clock) library for making an alarm~~
- [Twitter Tweets API](https://github.com/Rakibul73/twitter_tweets_api)
- [fb grp API](https://github.com/Rakibul73/fb_grp_api)
- [Android Alarm Manager Plus](https://pub.dev/packages/android_alarm_manager_plus) library for making background task
- [Awesome Dialog](https://pub.dev/packages/awesome_dialog) library for making awesome dialog ui
- [Flutter Facebook Auth](https://pub.dev/packages/flutter_facebook_auth) library for making fb login & getting user access_token
- removed ~~[WorkManager](https://pub.dev/packages/workmanager) library for making background task~~
- [SharedPreferences](https://pub.dev/packages/shared_preferences) library for persistent storage
- [Twitter Developer API](https://developer.twitter.com/en/docs)
- [Facebook Developer API](https://developers.facebook.com/docs/)