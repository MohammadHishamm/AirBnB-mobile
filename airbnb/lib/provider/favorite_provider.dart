import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  // List to store favorite place IDs
  List<String> _favoriteIds = [];
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Getter to access favorite place IDs
  List<String> get favorites => _favoriteIds;

  // Constructor to load favorite items when the provider is instantiated
  FavoriteProvider() {
    loadFavorite();
  }

  // Toggle the favorite state of a place (add or remove)
  void toggleFavorite(DocumentSnapshot place) async {
    String placeId = place.id;
    if (_favoriteIds.contains(placeId)) {
      _favoriteIds.remove(placeId); // Remove from favorites
      await _removeFavorite(placeId); // Remove from Firestore
    } else {
      _favoriteIds.add(placeId); // Add to favorites
      await _addFavorites(placeId); // Add to Firestore
    }
    notifyListeners(); // Notify listeners to update UI
  }

  // Check if a place is in favorites
  bool isExist(DocumentSnapshot place) {
    return _favoriteIds.contains(place.id);
  }

  // Add a place to favorites in Firestore
  Future<void> _addFavorites(String placeId) async {
    try {
      // Create or update the userFavorite collection with the placeId
      await firebaseFirestore
          .collection("userFavorites")
          .doc(placeId)
          .set({'isFavorite': true});
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  // Remove a place from favorites in Firestore
  Future<void> _removeFavorite(String placeId) async {
    try {
      // Delete the document from the userFavorite collection
      await firebaseFirestore.collection("userFavorites").doc(placeId).delete();
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  // Load favorite items from Firestore when the app starts or when necessary
  Future<void> loadFavorite() async {
    try {
      // Retrieve the list of favorites from Firestore
      QuerySnapshot snapshot =
          await firebaseFirestore.collection("userFavorites").get();
      // Map the documents to a list of place IDs
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error loading favorites: $e");
    }
    notifyListeners(); // Notify listeners to update UI after loading favorites
  }

  // Static method to access the provider from any context (optional but useful in some cases)
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
