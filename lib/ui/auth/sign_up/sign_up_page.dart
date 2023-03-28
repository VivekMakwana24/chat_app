import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/core/di/api/response/api_base/api_base.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/core/navigation/routes.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/res.dart';
import 'package:flutter_demo_structure/ui/auth/login/store/login_store.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/values/string_constants.dart';
import 'package:flutter_demo_structure/widget/app_utils.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:flutter_demo_structure/widget/button_widget_inverse.dart';
import 'package:flutter_demo_structure/widget/loading.dart';
import 'package:flutter_demo_structure/widget/text_form_filed.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobx/mobx.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isHidden = true;
  late GlobalKey<FormState> _formKey;
  late TextEditingController nameController, emailController, passwordController;
  late FocusNode nameNode, emailNode, passwordNode;

  ValueNotifier<bool> showLoading = ValueNotifier<bool>(false);
  var socialId, type = "S";
  List<ReactionDisposer>? _disposers;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameNode = FocusNode();
    emailNode = FocusNode();
    passwordNode = FocusNode();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: BaseAppBar(
          showTitle: false,
          leadingIcon: true,
        ),
        body: Container(
          width: 1.sw,
          height: 1.sh,
          child: SingleChildScrollView(
            child: ValueListenableBuilder(
              valueListenable: showLoading,
              builder: (context, bool value, child) => Loading(
                status: value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    30.0.VBox,
                    getHeaderContent(),
                    getSignUpForm(),
                    40.0.VBox,
                  ],
                ).wrapPadding(
                  padding: EdgeInsets.only(top: 0.h, left: 30.w, right: 30.w),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getHeaderContent() {
    return Column(
      children: [
        FlutterLogo(
          size: 0.15.sh,
        ),
        10.0.VBox,
        Text(
          StringConstant.signUp.toUpperCase(),
          style: textBold.copyWith(
            color: AppColor.primaryColor,
            fontSize: 28.sp,
          ),
        ),
      ],
    );
  }

  Widget getSignUpForm() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            25.0.VBox,
            AppTextField(
              controller: nameController,
              label: StringConstant.name,
              hint: StringConstant.name,
              keyboardType: TextInputType.name,
              validators: nameValidator,
              focusNode: nameNode,
              prefixIcon: IconButton(
                onPressed: null,
                icon: Image.asset(
                  Res.user,
                  color: AppColor.primaryColor,
                  height: 26.0,
                  width: 26.0,
                ),
              ),
            ).wrapPaddingHorizontal(20),
            10.0.VBox,
            AppTextField(
              controller: emailController,
              label: StringConstant.email,
              hint: StringConstant.email,
              keyboardType: TextInputType.emailAddress,
              validators: emailValidator,
              focusNode: emailNode,
              prefixIcon: IconButton(
                onPressed: null,
                icon: Image.asset(
                  Res.email,
                  color: AppColor.primaryColor,
                  height: 26.0,
                  width: 26.0,
                ),
              ),
            ).wrapPaddingHorizontal(20),
            10.0.VBox,
            AppTextField(
              label: StringConstant.password,
              hint: StringConstant.password,
              obscureText: _isHidden,
              validators: passwordValidator,
              controller: passwordController,
              focusNode: passwordNode,
              keyboardType: TextInputType.visiblePassword,
              keyboardAction: TextInputAction.done,
              maxLines: 1,
              maxLength: 15,
              prefixIcon: IconButton(
                onPressed: null,
                icon: Image.asset(
                  Res.password,
                  color: AppColor.primaryColor,
                  height: 26.0,
                  width: 26.0,
                ),
              ),
            ).wrapPaddingHorizontal(20),
            16.0.VBox,
            AppButtonInverse(
              StringConstant.signUp.toUpperCase(),
                  () {
                if (_formKey.currentState!.validate()) {
                  signUpAndNavigateToHome();
                }
              },
              elevation: 0.0,
            ).wrapPaddingHorizontal(20),
          ],
        ),
      ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Future<void> signUpAndNavigateToHome() async {
    try {
      showLoading.value = true;
      var userModel = FirebaseChatUser(
        deviceToken: '0',
        deviceType: kIsWeb
            ? 'w'
            : Platform.isIOS
            ? 'i'
            : 'A',
        isOnline: false,
        //await firebaseChatManager.fetchUserId(emailController.text.trim()),
        userEmail: emailController.text.trim(),
        userName: nameController.text.trim(),
        password: passwordController.text.trim(),
        createdAt: generateUTC(DateTime.now().toUtc()),
      );

      User? user = await firebaseChatManager.firebaseUserSignup(userModel);
      showLoading.value = false;
      if (user != null) {
        appDB.currentUserId = userModel.userId.toString();
        appDB.isLogin = true;
        appDB.user = userModel;
        navigator.pushReplacementNamed(RouteName.homePage);
      }
    } on Exception catch (e) {
      showLoading.value = false;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email or password is invalid! Please try again.'),
        duration: const Duration(seconds: 2),
      ));
      debugPrint('Error In Firebase $e');
    }
  }

  removeDisposer() {
    _disposers!.forEach((element) {
      element.reaction.dispose();
    });
  }
}
