import 'package:flutter/material.dart';
// Import PayPal checkout view package here
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class PaymentScreen extends StatelessWidget {
  final int price;
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
                  clientId:
                      "ARCsRnuVt4CJ0StI_0SQ0DIB-caYKiaxdgqq43wrnkj05ykLc43jEL3yeoCV3SdM5n1oyhsTqwxUDi6P", // Replace with your PayPal Client ID
                  secretKey:
                      "EFjbW5YajLaTTBT-e-hUhzLopF-FiEuCX8bHuSousbIWBnmx00AcxE1ZIG3zlmy33euAJQxb4XemDnZh", // Replace with your PayPal Secret Key
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
                    Navigator.pop(context); // Go back after success
                  },
                  onError: (error) {
                    print("Payment error: $error");
                    // Handle error (e.g., show an error message)
                    Navigator.pop(context); // Go back after error
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
