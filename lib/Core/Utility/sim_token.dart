import 'dart:convert';
import 'package:crypto/crypto.dart';

const _simSecret = 'some_super_secret_value'; // SAME AS BACKEND

String generateSimToken(String contact) {
  final normalized = contact.trim(); // e.g., +91XXXXXXXXXX
  final input = '$normalized:$_simSecret';
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes); // Correct usage
  return digest.toString();
}
