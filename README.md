# MBMessages

MBMessagesSwift is a plugin libary for [MBurger](https://mburger.cloud), that lets you display in app messages and manage push notifications in your app.

Using this library you can display the messages that you set up in the MBurger dashboard in your app. You can also setup and manage push notifications connected to your MBurger project.

# Installation

You can install the MBAudience SDK using pub, add this to your pubspec.yaml file:

``` yaml
dependencies:
  mbmessages: ^0.0.1
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
  themeForMessage: (message) => MBInAppMessageTheme(),
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