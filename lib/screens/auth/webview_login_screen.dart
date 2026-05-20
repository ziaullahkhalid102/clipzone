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
            _checkForCallback(url);
          },
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            if (uri.scheme == 'clipzone' && uri.host == 'auth') {
              _handleAuthCallback(uri);
              return NavigationDecision.prevent;
            }

            // Also check if the callback page has token in URL
            if (request.url.contains('/auth/google/callback') &&
                request.url.contains('state=mobile')) {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            if (change.url != null) {
              _checkForCallback(change.url!);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.loginUrl));
  }

  bool _callbackHandled = false;

  void _checkForCallback(String url) {
    if (_callbackHandled) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (uri.scheme == 'clipzone' && uri.host == 'auth') {
      _callbackHandled = true;
      _handleAuthCallback(uri);
      return;
    }

    // Extract token from callback page content
    if (url.contains('/auth/google/callback') || url.contains('state=mobile')) {
      _controller.runJavaScriptReturningResult(
        'document.querySelector("script")?.textContent || document.body.innerHTML || ""',
      ).then((result) {
        final content = result.toString();
        final tokenMatch = RegExp(r'token=([^&"\\]+)').firstMatch(content);
        if (tokenMatch != null && !_callbackHandled) {
          _callbackHandled = true;
          final token = tokenMatch.group(1)!;
          _handleAuthCallback(Uri.parse('clipzone://auth?token=$token'));
        }
      }).catchError((_) {});
    }
  }

  Future<void> _handleAuthCallback(Uri uri) async {
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

    if (token != null) {
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
