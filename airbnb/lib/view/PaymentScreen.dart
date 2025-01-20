import 'package:airbnb/view/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:airbnb/view/tripscreen.dart';

class PaymentScreen extends StatelessWidget {
  final int price;
  final String title;
  final String placeid;

  const PaymentScreen(
      {super.key,
      required this.price,
      required this.title,
      required this.placeid});

  Future<void> savePaymentToFirestore(String userId, Map params) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('PaymentCollection')
          .doc(userId)
          .set({}, SetOptions(merge: true));
      await firestore
          .collection('PaymentCollection')
          .doc(userId)
          .collection('placesPaid')
          .doc(placeid)
          .set({'ispaid': true});
      print("Payment details saved to Firestore.");
    } catch (e) {
      print("Error saving payment details: $e");
    }
  }

  Future<void> updatePlaceStatus(String placeId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('myAppCollection').doc(placeId).update({
        'isActive': false,
      });
      print("Place status updated successfully.");
    } catch (e) {
      print("Error updating place status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (userId.isEmpty) {
              // Show an error if the user is not logged in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You must be logged in to make a payment."),
                ),
              );
              return;
            }

            // Navigate to PayPal Checkout View
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => PaypalCheckoutView(
                  sandboxMode: true,
                  clientId:
                      "Afd0HkN3wFNCtrMwIgpMk-ypG_l0fT8hSeKjUnZK-0LoRF4DyasYbIiry0bTEnKnD6rXStahUGRnj7iL", // Replace with your PayPal Client ID
                  secretKey:
                      "EBe2ky_pzrEdCISV7-cbhonR6tRBv8MgdBPKRZbjVIYP7tK9a-pKDfUdTQ7ZPXTv5TbqkjMpcwREk-d4", // Replace with your PayPal Secret Key
                  transactions: [
                    {
                      "amount": {
                        "total": price.toStringAsFixed(2),
                        "currency": "USD"
                      },
                      "description": "Payment for $title"
                    }
                  ],
                  note: "Contact us for any questions on your order.",
                  onSuccess: (Map params) {
                    print("Payment successful: $params");

                    // Save payment details to Firestore
                    savePaymentToFirestore(userId, params).then((_) {
                      // Update isActive field in myAppCollection
                      updatePlaceStatus(placeid).then((_) {
                        // Navigate to TripScreen on success
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppMainScreen(),
                          ),
                          (route) => false,
                        );
                      }).catchError((error) {
                        print("Failed to update place status: $error");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Error updating place status. Please try again."),
                          ),
                        );
                      });
                    }).catchError((error) {
                      print("Failed to save payment details: $error");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Error saving payment details. Please try again."),
                        ),
                      );
                    });
                  },
                  onError: (error) {
                    print("Payment error: $error");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Payment failed: $error"),
                      ),
                    );
                    Navigator.pop(context); // Go back after error
                  },
                  onCancel: () {
                    print('Payment canceled');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Payment was canceled."),
                      ),
                    );
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
