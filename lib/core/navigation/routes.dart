import 'package:flutter/material.dart';
import 'package:gotms_chat/ui/auth/login/login_page.dart';
import 'package:gotms_chat/ui/auth/sign_up/sign_up_page.dart';
import 'package:gotms_chat/ui/home/line_chart_summary.dart';
import 'package:gotms_chat/ui/web_page.dart';
import 'package:gotms_chat/widget/web_widget.dart';

abstract class RouteName {
  static const String root = "/";
  static const String loginPage = "/login";
  static const String signUpPage = "/signUp";
  static const String homePage = "/home";
  static const String lineChart = "/lineChart";
  static const String webViewPage = "/webView";
  static const String webPage = "/webPage";
}

class Routes {
  static dynamic route() {
    return {
      RouteName.root: (BuildContext context) => Scaffold(
            body: CircularProgressIndicator.adaptive(),
          ),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    List<String>? pathComponents = settings.name?.split('/');
    debugPrint('pathComponents $pathComponents');

    final args = settings.arguments;
    final Uri uri = Uri.parse(settings.arguments as String? ?? ''); // Parse the URL

    var loginData;
    if (settings.name?.contains('/?login') ?? false) {
      Uri uri = Uri.parse(settings.name ?? '');
      loginData = uri.queryParameters['login']?.replaceAll('%20', '+').replaceAll(' ', '+');
      debugPrint('LOGIN QUERY PARAM ==> $loginData');
    }

    debugPrint("Route Name ${settings.name} args $args , QueryParam = $loginData");

    var page;
    switch (settings.name) {
      case RouteName.root:
        page = Scaffold(
          body: CircularProgressIndicator.adaptive(),
        );
        break;
      case RouteName.loginPage:
        page = LoginPage();
        break;

      case RouteName.signUpPage:
        page = SignUpPage();
        break;

      /*case RouteName.homePage:
        page = HomePage();
        break;*/

      case RouteName.homePage:
        var home = WebPage(
          queryParam: loginData,
        );
        page = home;
        break;

      case RouteName.webViewPage:
        page = WebViewPage(
          webViewInfo: args as WebViewInfoData,
        );
        break;

      default:
        var home = WebPage(
          queryParam: loginData,
        );
        page = home;
        break;
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(settings.name ?? ''),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name!.split} Coming soon..'),
        ),
      ),
    );
  }
}
