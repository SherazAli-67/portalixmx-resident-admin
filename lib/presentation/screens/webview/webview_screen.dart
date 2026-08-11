import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/loading_widget.dart';

class WebviewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebviewScreen({super.key, required this.title, required this.url});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {

  WebViewController? controller;
  int loadingPercentage = 0;
  @override
  void initState() {
    controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          debugPrint("Started Url: $url");

          loadingPercentage = 0;
        },
        onProgress: (progress) {
          loadingPercentage = progress;
        },
        onPageFinished: (url) {
          debugPrint("Finished Url: $url");
          loadingPercentage = 100;

        },
      ))
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: _buildWebViewWidget()
    );
  }

  Widget? _buildWebViewWidget() {
    if (controller == null) {
      return  Center(child: LoadingWidget(color: AppColors.primaryColor));
    }
    return Stack(
      children: [
        WebViewWidget(controller: controller!),
        loadingPercentage < 100
            ? LinearProgressIndicator(color: AppColors.btnColor, value: loadingPercentage / 100.0,)
            : const SizedBox.shrink(),

      ],
    );
  }
}
