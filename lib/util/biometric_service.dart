import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static Future<bool> authenticateUser() async {
    //initialize Local Authentication plugin.
    final LocalAuthentication _localAuthentication = LocalAuthentication();

    //status of authentication.
    bool isAuthenticated = false;

    //check if device supports biometrics authentication.
    bool isBiometricSupported = await _localAuthentication.isDeviceSupported();

    List<BiometricType> biometricTypes = await _localAuthentication.getAvailableBiometrics();

    print(biometricTypes);

    //if device supports biometrics, then authenticate.
    if (isBiometricSupported) {
      try {
        isAuthenticated = await _localAuthentication.authenticate(
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,
          ),
          localizedReason: 'Let OS determine authentication method',
        );
      } on PlatformException catch (e) {
        print(e);
      }
    }

    return isAuthenticated;
  }
}
