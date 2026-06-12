import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';

class WebPrivacyPolicyScreen extends StatefulWidget {
  const WebPrivacyPolicyScreen({super.key});

  @override
  State<WebPrivacyPolicyScreen> createState() => _WebPrivacyPolicyScreenState();
}

class _WebPrivacyPolicyScreenState extends State<WebPrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(ApiConstants.privacyPolicyUrl));
    
    // Web iframe loads almost immediately and manages its own loading state
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const WebScreenHeader(title: 'Privacy Policy'),
              const Divider(height: 1),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      child: WebViewWidget(controller: _controller),
                    ),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
