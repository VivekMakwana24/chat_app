import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/ui/auth/login/login_page.dart';
import 'package:flutter_demo_structure/ui/auth/sign_up/sign_up_page.dart';
import 'package:flutter_demo_structure/ui/home/line_chart_summary.dart';
import 'package:flutter_demo_structure/ui/navbar/navbar.dart';
import 'package:flutter_demo_structure/ui/splash.dart';
import 'package:flutter_demo_structure/ui/web/chat_screen/chat_screen.dart';
import 'package:flutter_demo_structure/widget/responsive_layout.dart';
import 'package:flutter_demo_structure/widget/web_widget.dart';

abstract class RouteName {
  static const String root = "splash";
  static const String loginPage = "/login";
  static const String signUpPage = "/signUp";
  static const String homePage = "/home";
  static const String lineChart = "/lineChart";
  static const String webViewPage = "/webView";
}

class Routes {
  static dynamic route() {
    return {
      RouteName.root: (BuildContext context) => Splash(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    List<String> pathComponents = settings.name!.split('/');
    debugPrint('pathComponents $pathComponents');

    final args = settings.arguments;
    debugPrint("Route Name ${settings.name} args $args ");
    var page;
    switch ('/' + pathComponents[1]) {
      case RouteName.root:
        page = Splash();
        break;
      case RouteName.loginPage:
        page = LoginPage();
        break;

      case RouteName.signUpPage:
        page = SignUpPage();
        break;
      case RouteName.lineChart:
        page = LineChartSummaryPage();
        break;

      /*case RouteName.homePage:
        page = HomePage();
        break;*/

      case RouteName.homePage:
        var home = ResponsiveLayout(
          webScreenLayout: WebChatScreen(path: pathComponents.length > 2 ? pathComponents[2] : null),
          tabletScreenLayout: MyBottomNavigationBar(),
          mobileScreenLayout: MyBottomNavigationBar(),
        );
        page = home;
        break;

      case RouteName.webViewPage:
        page = WebViewPage(
          webViewInfo: args as WebViewInfoData,
        );
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
