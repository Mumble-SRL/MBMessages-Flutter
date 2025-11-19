# MBMessages

MBMessages is a plugin libary for [MBurger](https://mburger.cloud), that lets you display in app messages and manage push notifications in your app.

Using this library you can display the messages that you set up in the MBurger dashboard in your app. You can also setup and manage push notifications connected to your MBurger project.

MBMessages depends on the following packages:

 - [mburger](https://pub.dev/packages/mburger)
 - [mpush](https://pub.dev/packages/mpush)
 - [device_info](https://pub.dev/packages/device_info)
 - [http](https://pub.dev/packages/http)
 - [path](https://pub.dev/packages/path)
 - [path_provider](https://pub.dev/packages/path_provider)
 - [shared_preferences](https://pub.dev/packages/shared_preferences)

# Installation

You can install the MBAudience SDK using pub, add this to your pubspec.yaml file:

``` yaml
dependencies:
  mbmessages: ^2.1.6
```

And then install packages from the command line with:

``` bash
$ flutter pub get
```


# Initialization

To initialize the SDK you have to add `MBMessages
` to the array of plugins of `MBurger`.

```dart
MBManager.shared.apiToken = 'YOUR_API_TOKEN';
MBManager.shared.plugins = [MBMessages()];
```
To show in app message correctly you have to embed your main widget in a `MBMessagesBuilder` like this:

```dart
@override
Widget build(BuildContext context) {
return MaterialApp(
  ...
    home: MBMessagesBuilder(
      child: Scaffold(
        ...
      ),
    ),
  );
}
```
Why? To present in app messages `MBMessages` uses the `showDialog` function that needs a `BuildContext`. Embedding your main `Scaffold` in a `MBMessagesBuilder` let the SDK know always what context to use to show in app messages.

## Initialize MBMessages with parameters

You can set a couples of parameters when initializing the `MBMessages` plugin:

```dart
MBMessages messagesPlugin = MBMessages(
  messagesDelay: 1,
  automaticallyCheckMessagesAtStartup: true,
  debug: false,
  themeForMessage: (context, message) => MBInAppMessageTheme(),
  onButtonPressed: (button) => _buttonPressed(button),
);

```

- **messagesDelay**: it's the time after which the messages will be displayed once fetched
- **automaticallyCheckMessagesAtStartup**: if the plugin should automatically check messages at startup. By default it's true.
- **debug**: if this is set to `true`, all the message returned by the server will be displayed, if this is set to `false` a message will appear only once for app installation. This is `false` by default
- **themeForMessage**: a function to provide a message theme (colors and fonts) for in app messages.
- **onButtonPressed**: a callback called when a button of an in app message iis pressed.

# Stylize in app messages

If you want to specify fonts and colors of the messages displayed you can use the `themeForMessage` function and provide a theme for the specified message. For each message you can specify the following properties:

- **backgroundColor**: the color of the background
- **titleStyle**: the text style for the title of the message
- **bodyStyle**: the text style for the body of the message
- **closeButtonColor**: the color of the close button
- **closeButtonBackgroundColor**: the background color of the close button
- **button1BackgroundColor**: the background color for the first button
- **button1TextStyle**: the text style for the first button.
- **button2BackgroundColor**: the background color for the second button
- **button2BorderColor**: the border color for the second button
- **button2TextStyle**: the text style for the second button

Example:

```dart
...

    MBManager.shared.plugins = [
      MBMessages(
        themeForMessage: (message) => _themeForMessage(message),
      ),
    ];
    
...

  MBInAppMessageTheme _themeForMessage(MBInAppMessage message) {
    if (message.style == MBInAppMessageStyle.bannerTop) {
      return MBInAppMessageTheme(
        titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      );
    } else {
      return MBInAppMessageTheme(
        titleStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.red,
        ),
      );
    }
  }
```

# Push notifications

With this plugin you can also manage the push notification section of MBurger, this is a wrapper around MPush, the underlying platform, so you should refer to the [MPush documentation 
](https://github.com/Mumble-SRL/MPush-Flutter) to understand the concepts and to start the push integration. In order to use `MBMessages` instead of `MPush` you have to do the following changes:

Set the push token like this:

```dart
MBMessages.pushToken = "YOUR_PUSH_TOKEN";
```

Configure the callbacks and Android native interface like this:

```dart
MBMessages.configurePush(
  onNotificationArrival: (notification) {
    print("Notification arrived: $notification");
  },
  onNotificationTap: (notification) {
    print("Notification tapped: $notification");
  },
  androidNotificationsSettings: MPAndroidNotificationsSettings(
    channelId: 'messages_example',
    channelName: 'mbmessages',
    channelDescription: 'mbmessages',
    icon: '@mipmap/icon_notif',
  ),
);
```

To configure the Android part you need to pass a `MPAndroidNotificationsSettings` to the configure sections, it has 2 parameters:

-  `channelId`: the id of the channel
-  `channelName`: the name for the channel
-  `channelDescription`: the description for the channel
-  `icon`: the default icon for the notification, in the example application the icon is in the res folder as a mipmap, so it's adressed as `@mipmap/icon_notif`, iff the icon is a drawable use `@drawable/icon_notif`.

## Request a token

To request a notification token you need to do the following things:

1. Set a callback that will be called once the token is received correctly from APNS/FCM 

``` dart
MBMessages.onToken = (token) {
    print("Token retrieved: $token");
}
```

2. Request the token using MPush:

``` dart
MBMessages.requestToken();
```

## Register to topics

Once you have a notification token you can register this device to push notifications and register to topics:

``` dart
MBMessages.onToken = (token) async {
  print("Token received $token");
  await MBMessages.registerDevice(token).catchError(
    (error) => print(error),
  );
  await MBMessages.registerToTopic(MPTopic(code: 'Topic')).catchError(
    (error) => print(error),
  );
  print('Registered');
};
```

The topic are instances of the `MPTopic` class which has 3 properties:

- `code`: the id of the topic
- *[Optional]* `title`: the readable title of the topic that will be displayed in the dashboard, if this is not set it will be equal to `code`.
- *[Optional]* `single`: if this topic represents a single device or a group of devices, by default `false`.

## MBurger topics

MBurger has 2 default topics that you should use in order to guarantee the correct functionality of the engagement platform:

* `MBMessages.projectPushTopic()`: this topic represents all devices registred to push notifications for this project
* `MBMessages.devicePushTopic()`: this topic represents the current device

```dart
await MBMessages.registerToTopics(
  [
    await MBMessages.projectPushTopic(),
    await MBMessages.devicePushTopic(),
    MPTopic(code: 'Topic'),
  ],
);
```

## Launch notification

If the application was launched from a notification you can retrieve the data of the notification like this, this will be `null` if the application was launched normally:

``` dart
Map<String, dynamic> launchNotification = await MBMessages.launchNotification();
print(launchNotification);
```

# Message Metrics

Using `MBMessages` gives you also the chanche to collect informations about your user and the push, those will be displyed on the [MBurger](https://mburger.cloud) dashboard. As described in the prervious paragraph, in order for this to function, you have to tell `MBMessages` that a push has arrived, if you're not seeing correct data make sure to have correctly followed the setup steps for described in the [MPush documentation 
](https://github.com/Mumble-SRL/MPush-Flutter).

# Automation

If messages have automation enabled they will be ignored and managed by the [MBAutomation SDK](https://github.com/Mumble-SRL/MBAutomation-Flutter.git) so make sure to include and configure the automation SDK correctly.