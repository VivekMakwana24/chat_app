import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/core/di/api/app_exceptions.dart';
import 'package:flutter_demo_structure/core/di/api/repo/uthentication_repository.dart';
import 'package:flutter_demo_structure/core/di/api/response/api_base/api_base.dart';
import 'package:flutter_demo_structure/core/locator.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/core/navigation/routes.dart';
import 'package:mobx/mobx.dart';

// part 'login_store.g.dart';

// class LoginStore = _LoginStoreBase with _$LoginStore;

abstract class _LoginStoreBase with Store {
  late SingleResponse loginResponse;

  @observable
  String? errorMessage;

  @action
  Future login(Map<String, dynamic> data) async {
    try {
      errorMessage = null;
      var commonStoreFuture = ObservableFuture<SingleResponse>(authRepo.login(data));
      loginResponse = await commonStoreFuture;

      if (loginResponse.code == "1") {
        navigator.pushNamedAndRemoveUntil(RouteName.homePage);
        appDB.isLogin = true;
      } else {
        errorMessage = loginResponse.message;
      }
    } on AppException catch (e) {
      errorMessage = e.toString();
    } catch (e, st) {
      debugPrint("onCatch.....");
      debugPrint(e.toString());
      debugPrint(st.toString());
      errorMessage = "False";
    }
  }
}

// final authStore = locator<LoginStore>();
