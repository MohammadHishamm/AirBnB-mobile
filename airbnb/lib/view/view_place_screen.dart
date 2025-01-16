import 'package:airbnb/components/adaptive_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:airbnb/view/place_details_screen.dart';

class DisplayUserPlaces extends StatefulWidget {
  const DisplayUserPlaces({super.key});

  @override
  State<DisplayUserPlaces> createState() => _DisplayUserPlacesState();
}

class _DisplayUserPlacesState extends State<DisplayUserPlaces> {
  List<DocumentSnapshot> userPlaces = [];
  Map<String, dynamic>? recentlyDeletedPlace;
  String? recentlyDeletedPlaceId;

  @override
  void initState() {
    super.initState();
    _loadUserPlaces();
  }

  Future<void> _loadUserPlaces() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('myAppCollection')
            .where('userid', isEqualTo: currentUser.uid)
            .get();

        setState(() {
          userPlaces = querySnapshot.docs;
        });
      }
    } catch (e) {
      print('Error loading user places: $e');
    }
  }

  void _deletePlace(int index, String placeId) async {
    try {
      // Temporarily store the deleted place data
      recentlyDeletedPlace = {
        'id': placeId,
        'data': userPlaces[index].data(),
      };
      recentlyDeletedPlaceId = placeId;

      // Remove the place locally
      setState(() {
        userPlaces.removeAt(index);
      });

      // Delete the place from Firestore
      await FirebaseFirestore.instance
          .collection('myAppCollection')
          .doc(placeId)
          .delete();

      // Show a SnackBar with Undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Place deleted'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: _restoreDeletedPlace,
          ),
        ),
      );
    } catch (e) {
      print('Error deleting place: $e');
    }
  }

  Future<void> _restoreDeletedPlace() async {
    if (recentlyDeletedPlace != null) {
      try {
        // Restore the place in Firestore
        await FirebaseFirestore.instance
            .collection('myAppCollection')
            .doc(recentlyDeletedPlaceId)
            .set(recentlyDeletedPlace!['data']);

        // Reload all user places to ensure consistency
        await _loadUserPlaces();

        // Clear the temporary storage
        recentlyDeletedPlace = null;
        recentlyDeletedPlaceId = null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Place restored successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring place: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Places"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
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

                          return Dismissible(
                            key: Key(place.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deletePlace(index, place.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlaceDetailScreen(place: place),
                                  ),
                                );
                              },
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
                                                    address ??
                                                        'Unknown location',
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
