import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:gotms_chat/core/navigation/navigation_service.dart';
import 'package:gotms_chat/fcm/PushNotificationsManager.dart';
import 'package:gotms_chat/firebase_options.dart';
import 'package:gotms_chat/util/firebase_chat_manager/algolia_coverter.dart';
import 'package:gotms_chat/util/firebase_chat_manager/firebase_chat_manager.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:gotms_chat/values/string_constants.dart';
import 'package:gotms_chat/values/theme.dart';
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

  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();

    Hive
      ..init(appDocumentDir.path)
      ..registerAdapter(FirebaseChatUserAdapter());
  } else {
    Hive.registerAdapter(FirebaseChatUserAdapter());
  }

  await setupLocator();
  await locator.isReady<AppDB>();
  setPathUrlStrategy();

  // usePathUrlStrategy();

  //await Firebase.initializeApp();
  PushNotificationsManager().init();

  // String para1 = Uri.base.queryParameters["para1"];

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
      useInheritedMediaQuery: true,
      builder: (_, __) => GetMaterialApp(
        title: StringConstant.appName,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        routes: Routes.route(),
        initialRoute: RouteName.root,
        onGenerateRoute: Routes.onGenerateRoute,
        onUnknownRoute: Routes.onUnknownRoute,
        /*home: ResponsiveLayout(
          webScreenLayout: WebChatScreen(),
          tabletScreenLayout: WebChatScreen(),
          mobileScreenLayout: MyBottomNavigationBar(),
        ),*/
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

final algolia = locator<Algolia>();
final algoliaService = locator<AlgoliaService>();
