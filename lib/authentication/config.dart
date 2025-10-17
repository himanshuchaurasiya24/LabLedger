import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String githubJsonRawUrl =
    "https://raw.githubusercontent.com/himanshuchaurasiya24/AndroidAppDevelopment/main/random_url.json";

const String localBaseUrl = "http://127.0.0.1:8000/";

late String globalBaseUrl;

Future<void> initializeBaseUrl() async {
  try {
    // Add timestamp to bust cache
    final uri = Uri.parse(githubJsonRawUrl).replace(
      queryParameters: {"t": DateTime.now().millisecondsSinceEpoch.toString()},
    );

    final response = await http.get(uri);
    debugPrint(response.statusCode.toString());

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      final hostedUrl = jsonBody["random_url"] as String?;

      if (hostedUrl != null && hostedUrl.isNotEmpty) {
        try {
          // Optional: Ping the hosted URL before using
          final ping = await http.get(Uri.parse(hostedUrl));
          if (ping.statusCode == 200) {
            globalBaseUrl = hostedUrl;
            debugPrint(globalBaseUrl);

            return;
          }
        } catch (_) {}
      }
    } else {}
  } catch (e) {
    //
  }

  // Fallback to local URL
  globalBaseUrl = localBaseUrl;
  debugPrint(globalBaseUrl);
}
