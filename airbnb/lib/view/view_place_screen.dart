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
      // Remove the place locally
      setState(() {
        userPlaces.removeAt(index);
      });

      // Delete the place from the main collection
      await FirebaseFirestore.instance.collection('myAppCollection').doc(placeId).delete();

      // Access the userFavorites collection to delete the place from all users' favorites
      final userFavoritesSnapshot = await FirebaseFirestore.instance.collection('userFavorites').get();

for (var userDoc in userFavoritesSnapshot.docs) {
  // Access the favorites subcollection for each user
  final favoritesSnapshot = await FirebaseFirestore.instance
      .collection('userFavorites')
      .doc(userDoc.id) // Ensure userDoc.id is valid
      .collection('favorites')
      .where(FieldPath.documentId, isEqualTo: placeId) // Ensure placeId is valid
      .get();

  for (var favoriteDoc in favoritesSnapshot.docs) {
    await FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(userDoc.id)
        .collection('favorites')
        .doc(favoriteDoc.id)
        .delete();
  }
}
    } catch (e) {
      print('Error deleting place: $e');
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
                          return Dismissible(
                            key: Key(place.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deletePlace(index, place.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaceDetailScreen(place: place),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), // Match the card's radius
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        place['image'], // Image URL from Firestore
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place['title'], // Title from Firestore
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Category: ${place['category']}",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Price: \$${place['price']}",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    place['address'] ?? 'Unknown location',
                                                    style: const TextStyle(fontSize: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Drag handle icon
                                      Icon(
                                        Icons.drag_handle_rounded,
                                        color: const Color.fromARGB(255, 0, 0, 0),
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
