import 'package:flutter/material.dart';
// Import PayPal checkout view package here
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentScreen extends StatelessWidget {
  final double price;
  final String title;

  const PaymentScreen({super.key, required this.price, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to PayPal Checkout View
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => PaypalCheckoutView(
                  sandboxMode: true,
                  clientId:  dotenv.env['PAYPAL_CLIENT_ID'] ,  // Replace with your PayPal Client ID
                  secretKey: dotenv.env['PAYPAL_SECRET_KEY'], // Replace with your PayPal Secret Key
                  transactions: [
                    {
                      "amount": {
                        "total": price.toString(),
                        "currency": "USD",
                        "details": {
                          "subtotal": price.toString(),
                          "shipping": '0',
                          "shipping_discount": 0
                        }
                      },
                      "description": "Payment for $title",
                      "item_list": {
                        "items": [
                          {
                            "name": title,
                            "quantity": '1',
                            "price": price.toString(),
                            "currency": "USD"
                          }
                        ]
                      }
                    }
                  ],
                  note: "Contact us for any questions on your order.",
                  onSuccess: (Map params) {
                    print("Payment successful: $params");
                    // Handle success (e.g., show a success message)
                    Navigator.pop(context);  // Go back after success
                  },
                  onError: (error) {
                    print("Payment error: $error");
                    // Handle error (e.g., show an error message)
                    Navigator.pop(context);  // Go back after error
                  },
                  onCancel: () {
                    print('Payment canceled');
                    // Handle cancellation (e.g., show a cancellation message)
                  },
                ),
              ),
            );
          },
          child: const Text('Pay with PayPal'),
        ),
      ),
    );
  }
}
