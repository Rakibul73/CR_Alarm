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

<!-- - [ ] Multi-language Support
    - [ ] Chinese
    - [ ] Spanish -->




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