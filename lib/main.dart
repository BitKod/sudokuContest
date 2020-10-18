import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/init/locale_keys.g.dart';
import 'core/init/string_extensions.dart';
import 'core/theme/themeManager.dart';
import 'inApp/models/user.dart';
import 'inApp/services/auth.dart';
import 'inApp/views/dashboard.dart';
import 'inApp/views/profile.dart';
import 'inApp/views/welcome.dart';

void main() async {
  await Hive.initFlutter('sudokuContest');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: AppConstants.SUPPORTED_LOCALE,
      path: AppConstants.LANG_PATH,
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false;
  FirebaseUser user;
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((changedUser) {
      setState(() {
        isAuthenticated = changedUser != null;
        user = changedUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>(
          create: (context) => FirebaseAuth.instance.onAuthStateChanged,
        ),
        StreamProvider<User>.value(value: AuthService().user),
        ChangeNotifierProvider<ThemeManager>(
          create: (context) => ThemeManager(),
        ),
      ],
      child: Consumer<ThemeManager>(builder: (context, settings, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: LocaleKeys.appStrings_sudokuContestApp.locale,
          theme: settings.getTheme(),
          initialRoute: isAuthenticated ? '/dashboard' : '/welcome',
          routes: {
            '/welcome': (context) => Welcome(),
            '/dashboard': (context) => Dashboard(),
            '/profile': (context) => Profile(
                  userUid: isAuthenticated ? user.uid : '',
                ),
            /* '/deneme': (context) => FlutterFirebaseAnimate(), */
          },
        );
      }),
    );
  }
}
