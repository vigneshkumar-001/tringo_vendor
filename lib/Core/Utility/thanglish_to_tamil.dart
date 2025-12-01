import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class  TanglishTamilHelper   {
  static Future<List<String>> transliterate(String input) async {
    final url = Uri.parse(
      'https://inputtools.google.com/request?text=$input&itc=ta-t-i0-und&num=5',
    );

    final response = await http.get(url);
    print(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data[0] == 'SUCCESS') {
        final List suggestions = data[1][0][1];
        return List<String>.from(suggestions);
      }
    }

    return [];
  }
  static void applySuggestion({
    required TextEditingController controller,
    required String suggestion,
    VoidCallback? onSuggestionApplied,
  }) {
    controller.text = suggestion;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    if (onSuggestionApplied != null) {
      onSuggestionApplied();
    }
  }
}
