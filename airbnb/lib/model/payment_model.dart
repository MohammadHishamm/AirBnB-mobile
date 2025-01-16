import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> savePaymentToFirebase(Payment payment) async {
  try {
    final CollectionReference ref = FirebaseFirestore.instance.collection("payments");

    final String paymentId = DateTime.now().toIso8601String() + Random().nextInt(1000).toString();

    // Save the payment object to Firestore
    await ref.doc(paymentId).set(payment.toMap());

    print("Payment successfully added to Firebase with ID: $paymentId");
  } catch (e) {
    print("Error saving payment to Firebase: $e");
    throw Exception('Failed to save payment: $e');
  }
}
class Payment {
  final String paymentId;
  final String userId;
  final double amount;
  final String paymentMethod; // PayPal, Credit Card, etc.
  final String paymentStatus; // e.g., "Completed", "Pending", "Failed"
  final String transactionId; // PayPal transaction ID
  final String date;
  final String placeId; // New field to link Payment with Place

  Payment({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    required this.date,
    required this.placeId, // Add this parameter
  });

  // Convert Payment object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId, // Include placeId in the map
      'paymentId': paymentId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'date': date,
    };
  }

}
