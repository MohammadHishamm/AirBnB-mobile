import 'package:airbnb/components/adaptive_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DisplayTripScreen extends StatefulWidget {
  const DisplayTripScreen({super.key});

  @override
  State<DisplayTripScreen> createState() => _DisplayTripState();
}

class _DisplayTripState extends State<DisplayTripScreen> {
  List<DocumentSnapshot> userPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadUserPlaces();
  }

  Future<void> _loadUserPlaces() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Step 1: Get the paid places from the PaymentCollection
        final querySnapshot = await FirebaseFirestore.instance
            .collection('PaymentCollection')
            .doc(currentUser.uid)
            .collection('placesPaid')
            .get();

        // Step 2: Fetch the place details from myAppCollection using the placeid
        List<DocumentSnapshot> places = [];
        for (var doc in querySnapshot.docs) {
          final placeId = doc.id;
          final placeSnapshot = await FirebaseFirestore.instance
              .collection('myAppCollection')
              .doc(placeId)
              .get();
          if (placeSnapshot.exists) {
            places.add(placeSnapshot);
          }
        }

        setState(() {
          userPlaces = places; // Store the fetched places
        });
      }
    } catch (e) {
      print('Error loading user places: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Trips",
            style: TextStyle(
              fontSize: 32,
            )),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userPlaces.isEmpty
                  ? Center(
                      child: Text(
                        "No Airbnb added yet",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: userPlaces.length,
                        itemBuilder: (context, index) {
                          final place = userPlaces[index];
                          final String title = place['title'];
                          final int price = place['price'];
                          final String image = place['image'];
                          final String address = place['address'];
                          final String category = place['category'];

                          return GestureDetector(
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Match the card's radius
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    AdaptiveImage(
                                      imageSource: image, // Image URL
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title, // Title from Firestore
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Category: $category",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Price: \$$price",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 16,
                                                  color: Colors.redAccent),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  address ?? 'Unknown location',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.drag_handle_rounded,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
