import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'app_snackbar.dart';

class  CallHelper  {
  CallHelper._(); // prevent instantiation

  static Future<void> openMap({
    required BuildContext context,
    required String latitude,
    required String longitude,
  }) async {
    final Uri googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        googleMapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showError(context, 'Could not open Google Maps');
      }
    } catch (e) {
      debugPrint('Error launching map: $e');
      _showError(context, 'Failed to open map');
    }
  }

  static void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static Future<void> openDialer({required BuildContext context, required String rawPhone}) async {
    if (rawPhone == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    // Remove spaces and common formatting characters
    final sanitized = rawPhone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (sanitized.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid phone number')));
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: sanitized, // e.g. +919885555555
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open dialer: $e')));
    }
  }

  static Future<void> openWhatsapp({
    required BuildContext context,
    required String phone,
    String? message,
  }) async {
    // 1) Digits மட்டும் வைத்துக்கோ
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // 2) 10 digit மட்டும் இருந்தா India என்று assume பண்ணு
    if (digits.length == 10) {
      digits = '91$digits';
    }

    final encodedMsg = Uri.encodeComponent(message ?? '');

    final whatsappUri = Uri.parse(
      'whatsapp://send?phone=$digits&text=$encodedMsg',
    );

    final webUri = Uri.parse('https://wa.me/$digits?text=$encodedMsg');

    try {
      print('WHATSAPP URI  : $whatsappUri');
      print('WA.ME URI     : $webUri');

      final canWhats = await canLaunchUrl(whatsappUri);
      print('canLaunch whatsapp:// = $canWhats');

      if (canWhats) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }

      final canWeb = await canLaunchUrl(webUri);
      print('canLaunch wa.me = $canWeb');

      if (canWeb) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      AppSnackBar.info(
        context,
        'WhatsApp or WhatsApp Web not available on this device',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open WhatsApp: $e')));
    }
  }

//
// static Future<void> openWhatsapp({
//   required BuildContext context,
//   required String phone,
//   String? message,
// }) async {
//   String normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
//   if (!normalized.startsWith('+')) {
//     normalized = '+91$normalized';
//   }
//
//   final encodedMsg = Uri.encodeComponent(message ?? '');
//   final uri = Uri.parse('https://wa.me/$normalized?text=$encodedMsg');
//
//   try {
//     final can = await canLaunchUrl(uri);
//     if (!can) {
//       AppSnackBar.info(context, 'WhatsApp not available on this device');
//
//       return;
//     }
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   } catch (e) {
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Could not open WhatsApp: $e')));
//   }
// }
}
