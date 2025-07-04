import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // For iOS Simulator / macOS: use localhost
  // For Android Emulator: use 10.0.2.2
  static const _host = 'localhost:4242';
  static const _protocol = 'http';
  // If you deploy your server, swap _host (and protocol) to your production URL.

  static Uri get _endpoint => Uri.parse('$_protocol://$_host/create-payment-intent');

  /// Calls your backend to create a Stripe PaymentIntent and returns its clientSecret.
  static Future<String> createPaymentIntent() async {
    final response = await http.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create PaymentIntent: ${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!json.containsKey('clientSecret')) {
      throw Exception('PaymentIntent response missing clientSecret');
    }

    return json['clientSecret'] as String;
  }
}
