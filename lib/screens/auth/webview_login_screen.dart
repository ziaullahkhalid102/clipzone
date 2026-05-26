import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../home_screen.dart';

class WebViewLoginScreen extends StatefulWidget {
  final String loginUrl;

  const WebViewLoginScreen({super.key, required this.loginUrl});

  @override
  State<WebViewLoginScreen> createState() => _WebViewLoginScreenState();
}

class _WebViewLoginScreenState extends State<WebViewLoginScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _callbackHandled = false;
  Timer? _tokenCheckTimer;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            _checkForToken(url);
          },
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'clipzone' && uri.host == 'auth') {
              _handleToken(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            if (change.url != null) {
              _checkForToken(change.url!);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.loginUrl));
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  void _checkForToken(String url) {
    if (_callbackHandled) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Direct clipzone:// scheme
    if (uri.scheme == 'clipzone' && uri.host == 'auth') {
      _handleToken(uri);
      return;
    }

    // Callback page - extract token from page content
    if (url.contains('/auth/google/callback') || url.contains('state=mobile')) {
      _tokenCheckTimer?.cancel();
      // Try multiple times with delay - page might not be fully loaded
      int attempts = 0;
      _tokenCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (_callbackHandled || attempts >= 10) {
          timer.cancel();
          return;
        }
        attempts++;
        _extractTokenFromPage();
      });
      // Also try immediately
      _extractTokenFromPage();
    }
  }

  void _extractTokenFromPage() {
    if (_callbackHandled) return;

    _controller.runJavaScriptReturningResult(
      'document.body ? document.body.innerHTML : ""',
    ).then((result) {
      if (_callbackHandled) return;
      final content = result.toString();
      final tokenMatch = RegExp(r'token=([A-Za-z0-9_\-\.]+)').firstMatch(content);
      if (tokenMatch != null) {
        _callbackHandled = true;
        _tokenCheckTimer?.cancel();
        final token = tokenMatch.group(1)!;
        _handleToken(Uri.parse('clipzone://auth?token=$token'));
      }
    }).catchError((_) {});

    // Also try getting full page source
    _controller.runJavaScriptReturningResult(
      'document.documentElement ? document.documentElement.outerHTML : ""',
    ).then((result) {
      if (_callbackHandled) return;
      final content = result.toString();
      final tokenMatch = RegExp(r'token=([A-Za-z0-9_\-\.]+)').firstMatch(content);
      if (tokenMatch != null) {
        _callbackHandled = true;
        _tokenCheckTimer?.cancel();
        final token = tokenMatch.group(1)!;
        _handleToken(Uri.parse('clipzone://auth?token=$token'));
      }
    }).catchError((_) {});
  }

  Future<void> _handleToken(Uri uri) async {
    final token = uri.queryParameters['token'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (token != null && token.isNotEmpty) {
      final auth = context.read<AuthProvider>();
      await auth.handleLoginCallback(token);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Sign In with Google'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
        ],
      ),
    );
  }
}
