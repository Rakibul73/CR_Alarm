<div align="center">
  <h1>CR Alarm</h1>


> Autmatic alarm - based on latest tweet

[![](https://skillicons.dev/icons?i=flutter,dart,vscode,androidstudio)]()
</div>
<hr/>
The CR Alarm App is a Flutter-based Android app that auto set alarms based on the time of the latest tweets of a specific Twitter user that fetches from api. When that specific user tweets and it sets an alarm so that you don't miss that user's posts, even if you sleep.
<hr/>

## One usecase
Suppose In university, there is a CR(Class Representative) in your class. He recieves the class schedule from teachers and post it in fb group. But you don't know when he will post or sometimes teachers tell the CR about class schedule 15/30 minutes before when you are in sound sleep..... so you know !! Now it will be amazing if there is an alarm app that can rings only when CR posted a class schedule. Now you don't have to miss any class again in you life. 
But it's now only support twitter post/tweets. if this CR person post a tweet in twiiter only then it sets alarm.
FB support will add in future.

## Download latest version from [here](https://github.com/Rakibul73/CR_Alarm/releases/latest)
## Features

- [x] Auto sets alarm
- [x] Making a api backend & hosting
- [x] Auto fetching tweets/post from api
- [x] Adding Background service (App can be closed from recent tab)
- [ ] Making a functional UI
- [ ] Allow users the ability to select whose tweets or posts they want to follow.
- [ ] Adding Facebook api support
- [ ] Allow users the ability to select which group posts they want to follow.
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
- [Android Alarm Manager Plus](https://pub.dev/packages/android_alarm_manager_plus) library for making background task
- removed ~~[WorkManager](https://pub.dev/packages/workmanager) library for making background task~~
- [SharedPreferences](https://pub.dev/packages/shared_preferences) library for persistent storage
- [Twitter Developer API](https://developer.twitter.com/en/docs)