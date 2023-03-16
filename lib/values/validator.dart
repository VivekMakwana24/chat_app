import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_demo_structure/widget/validtor_custom.dart';

final mobileValidator = MultiValidator([
  RequiredValidator(errorText: kEnterMobileNumber),
  MinLengthValidator(10, errorText: kEnterValidMobileNumber),
]);
final mobileCodeValidator = MultiValidator([
  RequiredValidator(errorText: kEnterCountryCode),
]);
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: kEnterPassword),
  MinLengthValidator(6, errorText: kEnterValidPassword),
]);
final confPasswordValidator = MultiValidator([
  RequiredValidator(errorText: kEnterConfPassword),
  MinLengthValidator(6, errorText: kEnterValidPassword),
]);
final userNameValidator = MultiValidator([
  RequiredValidator(errorText: kEnterUserName),
  MinLengthValidator(3, errorText: kEnterValidUserName),
]);
final nameValidator = MultiValidator([
  RequiredValidator(errorText: kEnterName),
  MinLengthValidator(3, errorText: kEnterName),
]);
final firstNameValidator = MultiValidator([
  RequiredValidator(errorText: kEnterFirstName),
  MinLengthValidator(3, errorText: kEnterValidFirstName),
]);
final lastNameValidator = MultiValidator([
  RequiredValidator(errorText: kEnterLastName),
  MinLengthValidator(3, errorText: kEnterValidLastName),
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: kEnterEmailAddress),
  EmailValidator(errorText: kEnterValidEmailAddress),
]);

final discriptionIssueValidator = MultiValidator([
  RequiredValidator(errorText: kEnterDescription),
]);
final commonValidator = MultiValidator([
  LYDPhoneValidator(
    errorText: kEmptyField,
    emailInvalid: kEnterValidEmailAddress,
  ),
]);

const kEmptyField = 'Please enter email';

const kEnterCountryCode = 'Please enter country code';

const kEnterMobileNumber = 'Please enter mobile number';
const kEnterValidMobileNumber = 'Please enter valid mobile number';

const kEnterValidEmailAddress = 'Please enter valid email';
const kEnterEmailAddress = 'Please enter email';

const kEnterUserName = 'Please enter user name';
const kEnterValidUserName = 'Please enter at least 3 characters for user name';

const kEnterName = 'Please enter name';

const kEnterFirstName = 'Please enter first name';
const kEnterValidFirstName = 'Please enter at least 3 characters for first name';

const kEnterLastName = 'Please enter last name';
const kEnterValidLastName = 'Please enter at least 3 characters for last name';

const kEnterConfPassword = 'Please enter confirm password';
const kEnterPassword = 'Please enter password';
const kEnterValidPassword = 'Password should be 6 or more characters';

const kPleaseEnterOtp = 'Please enter OTP';
const kPleaseEnterValidOtp = 'Please enter valid OTP';

const kConfirm = "Confirm";
const kLogoutMsg = "Are you sure \n\nYou want to logout?";
const kDeleteAccount = "Are you sure \n\nYou want to delete account?";

const kEnterDescription = 'Please enter description';
