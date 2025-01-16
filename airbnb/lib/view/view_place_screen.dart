import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final CollectionReference placesRef =
      FirebaseFirestore.instance.collection("myAppCollection");

  // Temporary storage for the last deleted place
  Map<String, dynamic>? recentlyDeletedPlace;
  String? recentlyDeletedPlaceId;

  Future<void> deletePlace(String placeId, Map<String, dynamic> placeData) async {
    try {
      // Store the deleted place temporarily
      recentlyDeletedPlace = placeData;
      recentlyDeletedPlaceId = placeId;

      // Delete the place
      await placesRef.doc(placeId).delete();

      // Show a SnackBar with Undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Place deleted'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: restoreDeletedPlace,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting place: $e')),
      );
    }
  }

  Future<void> restoreDeletedPlace() async {
    if (recentlyDeletedPlace != null && recentlyDeletedPlaceId != null) {
      try {
        // Restore the place
        await placesRef.doc(recentlyDeletedPlaceId).set(recentlyDeletedPlace!);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Places"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: placesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No places available."),
            );
          }

          final places = snapshot.data!.docs;

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final String placeId = place.id;
              final Map<String, dynamic> placeData = place.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(placeId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  deletePlace(placeId, placeData);
                },
                child: ListTile(
                  leading: placeData.containsKey('image')
                      ? Image.network(
                          placeData['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.place),
                  title: Text(placeData['title'] ?? 'Untitled Place'),
                  subtitle: Text(placeData['category'] ?? 'No Category'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
