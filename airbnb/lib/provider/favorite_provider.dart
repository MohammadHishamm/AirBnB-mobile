import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<String> get favorites => _favoriteIds;

  FavoriteProvider() {
    loadFavorite();
  }

  void toggleFavorite(DocumentSnapshot place, BuildContext context) async {
    String userId = auth.currentUser?.uid ?? "";
    String placeId = place.id;
    if (userId.isEmpty) return;

    String message;

    if (_favoriteIds.contains(placeId)) {
      _favoriteIds.remove(placeId);
      await _removeFavorite(userId, placeId);
      message = "Removed from Favorites";
    } else {
      _favoriteIds.add(placeId);
      await _addFavorite(userId, placeId);
      message = "Added to Favorites";
    }

    // Notify listeners for UI updates
    notifyListeners();

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration:
            const Duration(seconds: 2), // SnackBar will be shown for 3 seconds
      ),
    );
  }

  bool isExist(DocumentSnapshot place) {
    return _favoriteIds.contains(place.id);
  }

  Future<void> _addFavorite(String userId, String placeId) async {
    try {
      await firebaseFirestore
          .collection("userFavorites")
          .doc(userId)
          .collection("favorites")
          .doc(placeId)
          .set({'isFavorite': true});
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  Future<void> _removeFavorite(String userId, String placeId) async {
    try {
      await firebaseFirestore
          .collection("userFavorites")
          .doc(userId)
          .collection("favorites")
          .doc(placeId)
          .delete();
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  Future<void> loadFavorite() async {
    String userId = auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    try {
      QuerySnapshot snapshot = await firebaseFirestore
          .collection("userFavorites")
          .doc(userId)
          .collection("favorites")
          .get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error loading favorites: $e");
    }
    notifyListeners();
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
