import 'package:bot_toast/bot_toast.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/notifier/post_notifier.dart';
import 'package:instapost/screens/feed.dart';
import 'package:instapost/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapost/notifier/auth_notifier.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostNotifier(),
        ),
      ],
      child: MyApp(),
    ));

class MyApp extends StatefulWidget {
 
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [BotToastNavigatorObserver()],
        title: 'instaPost',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue
        ),
        // theme: ThemeData(
        //   fontFamily: "PTSans",
        //   primarySwatch: Colors.blue,
        //   accentColor: Colors.lightBlue,
        // ),
        home: SplashScreen.navigate(name: "fonts/splash.flr", next:(_)=> Consumer<AuthNotifier>(
          builder: (context, notifier, child) {
            return notifier.user != null ? Feed() : Login();
          },
        ),
        until:()=> Future.delayed(Duration(seconds: 2)),
        backgroundColor: CupertinoColors.white,
        startAnimation: "play",
        ) 
      ),
    );
  }
}
