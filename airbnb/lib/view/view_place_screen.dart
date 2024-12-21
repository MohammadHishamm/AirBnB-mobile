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
      setState(() {
        userPlaces.removeAt(index);
      });
      await FirebaseFirestore.instance.collection('myAppCollection').doc(placeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Place deleted")),
      );
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
                      child: ReorderableListView.builder(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) newIndex--;
                            final item = userPlaces.removeAt(oldIndex);
                            userPlaces.insert(newIndex, item);
                          });
                        },
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        place['image'], // Image URL from Firestore
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          place['title'], // Title from Firestore
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
