// lib/screens/coffee_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'payment_service.dart';

class CoffeePaymentScreen extends StatefulWidget {
  const CoffeePaymentScreen({Key? key}) : super(key: key);

  @override
  State<CoffeePaymentScreen> createState() => _CoffeePaymentScreenState();
}

class _CoffeePaymentScreenState extends State<CoffeePaymentScreen> {
  bool _loading = false;

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      // 1. Create PaymentIntent on your backend
      final clientSecret = await PaymentService.createPaymentIntent();

      // 2. Initialize the PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Daily Dare',

          // Replace `true` with a PaymentSheetApplePay object:
          applePay: PaymentSheetApplePay(
            merchantCountryCode: 'US', // your two-letter country code
          ),

          // Replace `true` with a PaymentSheetGooglePay object:
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US', // your two-letter country code
            testEnv: true,             // set to false in production
          ),

          // You can also specify style, customer details, etc.
          style: ThemeMode.system,
        ),
      );

      // 3. Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Success: thank user & return home
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('☕ Thanks for the coffee!')),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on StripeException catch (e) {
      // User canceled or error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error.localizedMessage ?? 'Payment canceled')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed, please try again')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buy Me a Coffee'),
        backgroundColor: Colors.yellow[700],
      ),
      body: SafeArea(
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mascot / Coffee image
                      Image.asset(
                        'assets/logo_coffee.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),

                      // Message
                      const Text(
                        'Rules are rules.\nBuy me a coffee. It\'s just a dollar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),

                      // Pay button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _pay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Alright, alright...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Maybe later
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Maybe later',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
