import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:tringo_vendor_new/Presentation/subscription/Model/ccavenue_models.dart';

class CcAvenueCheckoutResult {
  final bool callbackReached;
  final bool cancelled;
  final String? encResp;

  const CcAvenueCheckoutResult({
    required this.callbackReached,
    required this.cancelled,
    this.encResp,
  });
}

class CcAvenueCheckoutScreen extends StatefulWidget {
  final CcAvenueInitData initData;

  const CcAvenueCheckoutScreen({
    super.key,
    required this.initData,
  });

  @override
  State<CcAvenueCheckoutScreen> createState() => _CcAvenueCheckoutScreenState();
}

class _CcAvenueCheckoutScreenState extends State<CcAvenueCheckoutScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;

  Future<bool> _tryLaunchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      return ok;
    } catch (_) {
      return false;
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isCallbackUrl(Uri uri) {
    final p = uri.path.toLowerCase();
    return p.contains('/subscriptions/ccavenue/callback');
  }

  bool _isCancelUrl(Uri uri) {
    final cancel = widget.initData.cancelUrl.trim();
    if (cancel.isEmpty) return false;
    final u = Uri.tryParse(cancel);
    if (u == null) return false;
    return uri.scheme == u.scheme && uri.host == u.host && uri.path == u.path;
  }

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (p) => setState(() => _progress = p),
              onPageFinished: (_) => setState(() => _finished = true),
              onNavigationRequest: (req) {
                final uri = Uri.tryParse(req.url);
                if (uri == null) return NavigationDecision.navigate;

                // UPI and other payment app handoffs typically use non-http schemes.
                // We open them in an external application for best compatibility.
                final scheme = uri.scheme.toLowerCase();
                if (scheme.isNotEmpty && scheme != 'http' && scheme != 'https') {
                  () async {
                    final ok = await _tryLaunchExternal(req.url);
                    if (!ok && mounted) {
                      _showInfo(
                        "Unable to open payment app. Please install a UPI app and try again.",
                      );
                    }
                  }();
                  return NavigationDecision.prevent;
                }

                if (_isCancelUrl(uri)) {
                  Navigator.of(context).pop(
                    const CcAvenueCheckoutResult(
                      callbackReached: false,
                      cancelled: true,
                    ),
                  );
                  return NavigationDecision.prevent;
                }

                if (_isCallbackUrl(uri)) {
                  final encResp =
                      uri.queryParameters['encResp'] ??
                      uri.queryParameters['encresp'];

                  Navigator.of(context).pop(
                    CcAvenueCheckoutResult(
                      callbackReached: true,
                      cancelled: false,
                      encResp: (encResp ?? '').trim().isEmpty
                          ? null
                          : encResp!.trim(),
                    ),
                  );
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          );

    _controller.loadHtmlString(_buildAutoPostHtml(widget.initData));
  }

  String _buildAutoPostHtml(CcAvenueInitData init) {
    final action = init.form.action.trim().isNotEmpty
        ? init.form.action.trim()
        : init.gatewayUrl.trim();

    final enc = const HtmlEscape().convert(init.form.fields.encRequest);
    final access = const HtmlEscape().convert(init.form.fields.accessCode);

    // IMPORTANT:
    // - The backend gives us the exact fields it expects ("encRequest", "access_code").
    // - We post from an in-app WebView; no token is exposed here.
    return '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment</title>
  </head>
  <body>
    <form id="pay" action="$action" method="POST">
      <input type="hidden" name="encRequest" value="$enc" />
      <input type="hidden" name="access_code" value="$access" />
    </form>
    <script>
      (function() {
        try { document.getElementById('pay').submit(); } catch (e) {}
      })();
    </script>
  </body>
</html>
''';
  }

  Future<bool> _onWillPop() async {
    if (_progress > 0 && !_finished) return true;

    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel payment?'),
          content: const Text('Are you sure you want to close payment now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final showProgress = _progress < 100;
    return WillPopScope(
      onWillPop: () async {
        final ok = await _onWillPop();
        if (!mounted) return false;
        if (ok) {
          Navigator.of(context).pop(
            const CcAvenueCheckoutResult(
              callbackReached: false,
              cancelled: true,
            ),
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final ok = await _onWillPop();
              if (!mounted) return;
              if (ok) {
                Navigator.of(context).pop(
                  const CcAvenueCheckoutResult(
                    callbackReached: false,
                    cancelled: true,
                  ),
                );
              }
            },
          ),
        ),
        body: Column(
          children: [
            if (showProgress)
              LinearProgressIndicator(value: _progress / 100.0, minHeight: 2),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
