import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/firebase_options.dart';
import 'package:flutter_demo_structure/model/user_profile_response.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/firebase_chat_manager.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/values/string_constants.dart';
import 'package:flutter_demo_structure/values/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'core/db/app_db.dart';
import 'core/locator.dart';
import 'core/navigation/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  if(!kIsWeb){
    final appDocumentDir = await getApplicationDocumentsDirectory();

    Hive
      ..init(appDocumentDir.path)
      ..registerAdapter(FirebaseChatUserAdapter());
  }else{
    Hive.registerAdapter(FirebaseChatUserAdapter());
  }

  await setupLocator();
  await locator.isReady<AppDB>();
  setPathUrlStrategy();
  //await Firebase.initializeApp();
  // PushNotificationsManager().init();

  // Fixing App Orientation.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => runZonedGuarded(() {
      runApp(MyApp());
    }, (Object error, StackTrace stackTrace) {
      /// for debug:
      if (!kReleaseMode) {
        debugPrint('[Error]: ${error.toString()}');
        debugPrint('[Stacktrace]: ${stackTrace.toString()}');
      }
    }),
  );
}

class MyApp extends StatelessWidget {
  static GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        title: StringConstant.appName,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        routes: Routes.route(),
        onGenerateRoute: Routes.onGenerateRoute,
        onUnknownRoute: Routes.onUnknownRoute,
        initialRoute: RouteName.root,
      ),
    );
  }
}

/*ScrollConfiguration(
behavior: MyBehavior(),
child: child,
)*/

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

final firebaseFirestore = locator<FirebaseFirestore>();

final firebaseChatManager = locator<FirebaseChatManager>();

final firebaseStorage = locator<FirebaseStorage>();
