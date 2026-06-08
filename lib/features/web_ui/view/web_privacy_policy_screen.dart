import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
              _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 24),
            splashRadius: 24,
          ),
          const SizedBox(width: 16),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
      ),
    );
  }
}
