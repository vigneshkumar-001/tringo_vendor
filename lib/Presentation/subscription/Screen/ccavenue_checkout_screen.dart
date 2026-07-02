import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const MethodChannel _paymentLauncherChannel = MethodChannel(
    'tringo_vendor/payment_launcher',
  );

  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;
  String? _lastExternalLaunchUrl;
  DateTime? _lastExternalLaunchAt;

  Future<bool> _tryLaunchExternal(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    if (Platform.isAndroid) {
      try {
        final launched = await _paymentLauncherChannel.invokeMethod<bool>(
          'launchExternalPaymentUrl',
          {'url': trimmed},
        );
        if (launched == true) return true;
      } catch (_) {
        // Fall through to url_launcher below.
      }
    }

    final uri = Uri.tryParse(trimmed);
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

  bool _isExternalScheme(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme.isEmpty) return false;
    return !const {
      'http',
      'https',
      'about',
      'data',
      'javascript',
      'blob',
      'file',
    }.contains(scheme);
  }

  bool _isDuplicateExternalLaunch(String url) {
    final now = DateTime.now();
    final lastAt = _lastExternalLaunchAt;
    if (_lastExternalLaunchUrl == url &&
        lastAt != null &&
        now.difference(lastAt).inMilliseconds < 1500) {
      return true;
    }
    _lastExternalLaunchUrl = url;
    _lastExternalLaunchAt = now;
    return false;
  }

  Future<void> _recoverFromUnknownSchemePage() async {
    try {
      if (await _controller.canGoBack()) {
        await _controller.goBack();
      }
    } catch (_) {
      // Ignore recovery errors; user can still retry manually.
    }
  }

  Future<void> _handleExternalPaymentLaunch(
    String url, {
    bool recoverWebView = false,
  }) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty || _isDuplicateExternalLaunch(trimmed)) return;

    final ok = await _tryLaunchExternal(trimmed);

    if (recoverWebView) {
      unawaited(_recoverFromUnknownSchemePage());
    }

    if (!ok && mounted) {
      _showInfo(
        "Unable to open payment app. Please install a supported UPI app and try again.",
      );
    }
  }

  Future<void> _injectExternalSchemeBridge() async {
    try {
      await _controller.runJavaScript('''
(() => {
  if (window.__tringoPaymentBridgeInstalled) return;
  window.__tringoPaymentBridgeInstalled = true;

  const safeSchemes = /^(https?:|about:|data:|javascript:|blob:|file:)/i;

  function forwardIfExternal(rawUrl) {
    if (typeof rawUrl !== 'string') return false;
    const url = rawUrl.trim();
    if (!url || safeSchemes.test(url)) return false;

    try {
      if (window.TringoPaymentBridge && window.TringoPaymentBridge.postMessage) {
        window.TringoPaymentBridge.postMessage(url);
        return true;
      }
    } catch (_) {}

    return false;
  }

  document.addEventListener('click', (event) => {
    let node = event.target;
    while (node && node.tagName !== 'A') node = node.parentElement;
    if (!node) return;

    const href = node.getAttribute('href') || node.href || '';
    if (forwardIfExternal(href)) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  document.addEventListener('submit', (event) => {
    const form = event.target;
    if (!form) return;
    const action = form.getAttribute('action') || form.action || '';
    if (forwardIfExternal(action)) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  if (window.HTMLAnchorElement && HTMLAnchorElement.prototype) {
    const originalAnchorClick = HTMLAnchorElement.prototype.click;
    HTMLAnchorElement.prototype.click = function() {
      const href = this.getAttribute('href') || this.href || '';
      if (forwardIfExternal(href)) return;
      return originalAnchorClick.call(this);
    };
  }

  if (window.HTMLFormElement && HTMLFormElement.prototype) {
    const originalFormSubmit = HTMLFormElement.prototype.submit;
    HTMLFormElement.prototype.submit = function() {
      const action = this.getAttribute('action') || this.action || '';
      if (forwardIfExternal(action)) return;
      return originalFormSubmit.call(this);
    };
  }

  const originalOpen = window.open ? window.open.bind(window) : null;
  window.open = function(url, ...rest) {
    if (typeof url === 'string' && forwardIfExternal(url)) return null;
    return originalOpen ? originalOpen(url, ...rest) : null;
  };

  const originalAssign = window.location.assign.bind(window.location);
  window.location.assign = function(url) {
    if (typeof url === 'string' && forwardIfExternal(url)) return;
    return originalAssign(url);
  };

  const originalReplace = window.location.replace.bind(window.location);
  window.location.replace = function(url) {
    if (typeof url === 'string' && forwardIfExternal(url)) return;
    return originalReplace(url);
  };
})();
''');
    } catch (_) {
      // Ignore injection failures; navigation delegate still handles many cases.
    }
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
          ..addJavaScriptChannel(
            'TringoPaymentBridge',
            onMessageReceived: (message) {
              unawaited(
                _handleExternalPaymentLaunch(
                  message.message,
                  recoverWebView: true,
                ),
              );
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (p) => setState(() => _progress = p),
              onPageStarted: (_) => setState(() => _finished = false),
              onPageFinished: (_) {
                setState(() => _finished = true);
                unawaited(_injectExternalSchemeBridge());
              },
              onWebResourceError: (error) {
                // A UPI / intent redirect (upi:, phonepe:, tez:, intent:, ...)
                // that slipped past onNavigationRequest fails here as
                // ERR_UNKNOWN_URL_SCHEME. Launch the offending URL in the
                // external app instead of just recovering, so UPI payments
                // actually proceed.
                if (error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
                  final failedUrl = error.url?.trim() ?? '';
                  if (failedUrl.isNotEmpty) {
                    unawaited(
                      _handleExternalPaymentLaunch(
                        failedUrl,
                        recoverWebView: true,
                      ),
                    );
                  } else {
                    unawaited(_recoverFromUnknownSchemePage());
                  }
                }
              },
              onNavigationRequest: (req) {
                final uri = Uri.tryParse(req.url);
                if (uri == null) return NavigationDecision.navigate;

                // UPI and other payment app handoffs typically use non-http schemes.
                // We open them in an external application for best compatibility.
                if (_isExternalScheme(uri)) {
                  unawaited(
                    _handleExternalPaymentLaunch(
                      req.url,
                      recoverWebView: true,
                    ),
                  );
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
