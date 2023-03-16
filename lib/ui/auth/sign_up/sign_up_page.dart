import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/core/navigation/routes.dart';
import 'package:flutter_demo_structure/res.dart';
import 'package:flutter_demo_structure/ui/auth/login/sign_up_widget.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/values/string_constants.dart';
import 'package:flutter_demo_structure/widget/app_utils.dart';
import 'package:flutter_demo_structure/widget/button_widget_inverse.dart';
import 'package:flutter_demo_structure/widget/loading.dart';
import 'package:flutter_demo_structure/widget/text_form_filed.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobx/mobx.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isHidden = true;
  late GlobalKey<FormState> _formKey;
  late TextEditingController nameController,
      emailController,
      mobileController,
      passwordController,
      confPasswordController;
  late FocusNode mobileNode;
  ValueNotifier<bool> showLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isRead = ValueNotifier<bool>(false);

  late List<ReactionDisposer> _disposers;

  bool get isCurrent => !ModalRoute.of(context)!.isCurrent;

  var socialId, type = "S";
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('IN');

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    mobileController = TextEditingController();
    passwordController = TextEditingController();
    confPasswordController = TextEditingController();
    mobileNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confPasswordController.dispose();
    mobileNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: ValueListenableBuilder(
            valueListenable: showLoading,
            builder: (context, value, child) => Loading(
              status: showLoading.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  30.0.VBox,
                  getHeaderContent(),
                  getSignUpForm(),
                  40.0.VBox,
                  SignUpWidget(
                    fromLogin: false,
                    onTap: () => navigator.pop(),
                  ),
                  40.0.VBox,
                ],
              ).wrapPadding(
                padding: EdgeInsets.only(top: 0.h, left: 30.w, right: 30.w),
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
        10.0.VBox,
        Text(
          StringConstant.signUp.toUpperCase(),
          style: textBold.copyWith(
            color: AppColor.primaryColor,
            fontSize: 24.sp,
          ),
        ),
        10.0.VBox,
        Text(
          StringConstant.fillDetails,
          style: textLight.copyWith(
            color: AppColor.primaryColor,
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
              textCapitalization: TextCapitalization.sentences,
              validators: nameValidator,
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
              controller: mobileController,
              label: StringConstant.mobNumber,
              hint: StringConstant.mobNumber,
              keyboardType: TextInputType.phone,
              validators: mobileValidator,
              focusNode: mobileNode,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(10),
              ],
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: null,
                    icon: Image.asset(
                      Res.mobile,
                      color: AppColor.primaryColor,
                      height: 26.0,
                      width: 26.0,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '+${_selectedDialogCountry.phoneCode}',
                        style: textMedium.copyWith(
                          fontSize: 15.sp,
                        ),
                      ),
                      2.0.HBox,
                      Image.asset(
                        Res.arrow_down,
                        color: AppColor.osloGray,
                        height: 8.0,
                        width: 8.0,
                      ),
                    ],
                  ).wrapPaddingVertical(12.0).addGestureTap(() async => {
                        Future.delayed(Duration.zero, () {
                          mobileNode.unfocus();
                          mobileNode.canRequestFocus = false;
                        }),
                        await _openCountryPickerDialog(),
                        mobileNode.canRequestFocus = true,
                      }),
                  Container(
                    height: 12.0,
                    color: Colors.grey,
                    width: 1.5,
                  ).wrapPaddingHorizontal(12.0),
                ],
              ),
            ).wrapPaddingHorizontal(20),
            10.0.VBox,
            AppTextField(
              label: StringConstant.password,
              hint: StringConstant.password,
              obscureText: _isHidden,
              validators: passwordValidator,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              keyboardAction: TextInputAction.next,
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
            10.0.VBox,
            AppTextField(
              label: StringConstant.confPassword,
              hint: StringConstant.confPassword,
              obscureText: _isHidden,
              validators: confPasswordValidator,
              controller: confPasswordController,
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
            ValueListenableBuilder<bool>(
              valueListenable: _isRead,
              builder: (context, bool value, child) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    height: 20.0,
                    width: 20.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      splashColor: AppColor.transparent,
                      padding: EdgeInsets.zero,
                      icon: Image.asset(
                        Res.checked_box,
                        color: value ? AppColor.primaryColor : AppColor.osloGray,
                      ),
                      onPressed: () => _isRead.value = !value,
                    ),
                  ),
                  8.0.HBox,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: StringConstant.iAgree,
                        style: textLight.copyWith(
                          color: AppColor.greyColor,
                          fontSize: 14.sp,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: StringConstant.tNc,
                            style: textSemiBold.copyWith(
                              fontSize: 14.sp,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showMessage(StringConstant.tNc);
                              },
                          ),
                          TextSpan(
                            text: StringConstant.and,
                          ),
                          TextSpan(
                            text: StringConstant.privacyPolicy,
                            style: textSemiBold.copyWith(
                              fontSize: 14.sp,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showMessage(StringConstant.privacyPolicy);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).wrapPaddingHorizontal(20),
            18.0.VBox,
            AppButtonInverse(
              StringConstant.signUp.toUpperCase(),
              () {
                //navigator.pushNamed(RouteName.otpVerificationPage);
                if (_formKey.currentState!.validate()) {
                  if (passwordController.text.trim() != confPasswordController.text.trim()) {
                    showMessage(StringConstant.passwordMismatch);
                    return;
                  }
                  if (!_isRead.value) {
                    showMessage(StringConstant.acceptTnC);
                    return;
                  }
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

  signUpAndNavigateToHome() async {
    navigator.pushNamed(RouteName.homePage);
  }

  removeDisposer() {
    _disposers.forEach((element) {
      element.reaction.dispose();
    });
  }

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );

  Future _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          titlePadding: EdgeInsets.all(8.0),
          searchCursorColor: Colors.lightBlueAccent,
          searchInputDecoration: InputDecoration(hintText: 'Search...'),
          isSearchable: true,
          title: Text('Select your phone code'),
          onValuePicked: (Country country) => setState(() => _selectedDialogCountry = country),
          itemBuilder: _buildDialogItem,
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('US'),
            CountryPickerUtils.getCountryByIsoCode('IN'),
          ],
        ),
      );
}
