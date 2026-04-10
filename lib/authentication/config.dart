import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:labledger/constants/urls.dart';

late String globalBaseUrl;

String _normalizeBaseUrl(String baseUrl) {
  final trimmed = baseUrl.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.endsWith('/') ? trimmed : '$trimmed/';
}

Future<void> initializeBaseUrl() async {
  try {
    // Add timestamp to bust cache
    final uri = Uri.parse(AppUrls.githubJsonRaw).replace(
      queryParameters: {"t": DateTime.now().millisecondsSinceEpoch.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      final hostedUrl = jsonBody["ll"] as String?;

      if (hostedUrl != null && hostedUrl.isNotEmpty) {
        final normalizedHostedUrl = _normalizeBaseUrl(hostedUrl);
        try {
          // Optional: Ping the hosted URL before using
          final ping = await http.get(Uri.parse(normalizedHostedUrl));
          if (ping.statusCode == 200) {
            globalBaseUrl = normalizedHostedUrl;
            return;
          }
        } catch (_) {}
      }
    } else {}
  } catch (e) {
    //
  }

  // Fallback to local URL
  globalBaseUrl = _normalizeBaseUrl(AppUrls.localBaseUrl);
}
