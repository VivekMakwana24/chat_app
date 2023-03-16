import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/widget/base_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final WebViewInfoData webViewInfo;

  WebViewPage({required this.webViewInfo});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _isLoadingPage = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoadingPage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leadingIcon: true,
        showTitle: true,
        title: widget.webViewInfo.title,
        backgroundColor: AppColor.white,
        leadingWidgetColor: AppColor.osloGray,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebView(
              initialUrl: widget.webViewInfo.url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (finish) {
                setState(() {
                  _isLoadingPage = false;
                });
              },
            ),
            Visibility(
              visible: _isLoadingPage,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WebViewInfoData {
  String title, url;

  WebViewInfoData(this.title, this.url);
}
