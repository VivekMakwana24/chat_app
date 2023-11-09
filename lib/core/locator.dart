import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gotms_chat/core/di/api/repo/uthentication_repository.dart';
import 'package:gotms_chat/core/di/api/service/uthentication_services.dart';
import 'package:gotms_chat/util/firebase_chat_manager/algolia_coverter.dart';
import 'package:gotms_chat/util/firebase_chat_manager/firebase_chat_manager.dart';

import 'db/app_db.dart';
import 'di/api/http_client.dart';
import 'navigation/navigation_service.dart';

GetIt locator = GetIt.instance;

setupLocator() async {
  locator.registerSingleton(HttpClient());
  locator.registerSingleton(NavigationService());

  locator.registerSingletonAsync<AppDB>(() => AppDB.getInstance());

  locator.registerLazySingleton<UserAuthService>(() => UserAuthService());
  locator.registerLazySingleton<UserAuthRepository>(() => UserAuthRepository());
  locator.registerLazySingleton<Algolia>(() {
    return Algolia.init(
      applicationId: 'GGCEGPNUCL',
      apiKey: '8ac1985078780c5672edb1c419c92751',
    );
  });

  locator.registerLazySingleton<AlgoliaService>(() {
    return AlgoliaService();
  });

  locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  locator.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  locator.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  locator.registerSingleton<FirebaseChatManager>(FirebaseChatManager());
}
