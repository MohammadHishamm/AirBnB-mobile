import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final CollectionReference categoriesRef =
      FirebaseFirestore.instance.collection("AppCategory");
  final CollectionReference placesRef =
      FirebaseFirestore.instance.collection("myAppCollection");

  Map<String, dynamic>? recentlyDeletedCategory;
  String? recentlyDeletedCategoryId;

  Future<void> deleteCategory(String categoryId, String categoryTitle) async {
    try {
      final QuerySnapshot placesSnapshot =
          await placesRef.where('category', isEqualTo: categoryTitle).get();
      List<Map<String, dynamic>> associatedPlaces = [];
      for (var doc in placesSnapshot.docs) {
        associatedPlaces.add({
          'id': doc.id,
          'data': doc.data(),
        });
      }

      recentlyDeletedCategory = {
        'id': categoryId,
        'title': categoryTitle,
        'image': await categoriesRef
            .doc(categoryId)
            .get()
            .then((doc) => doc['image']),
        'associatedPlaces': associatedPlaces,
      };
      recentlyDeletedCategoryId = categoryId;

      for (var place in associatedPlaces) {
        await placesRef.doc(place['id']).delete();
        final favoritesDocRef = FirebaseFirestore.instance
            .collection('userFavorites')
            .doc(userId) // Reference the current user's document
            .collection('favorites')
            .doc(place['id']); // Reference the favorite by placeId directly
        // Check if the document exists
        final favoritesSnapshot = await favoritesDocRef.get();
        if (favoritesSnapshot.exists) {
          await favoritesDocRef.delete();
        }
      }

      await categoriesRef.doc(categoryId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category deleted'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: restoreDeletedCategory,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
    }
  }

  Future<void> restoreDeletedCategory() async {
    if (recentlyDeletedCategory != null) {
      try {
        await categoriesRef.doc(recentlyDeletedCategoryId).set({
          'title': recentlyDeletedCategory!['title'],
          'image': recentlyDeletedCategory!['image'],
        });

        for (var place in recentlyDeletedCategory!['associatedPlaces']) {
          await placesRef.doc(place['id']).set(place['data']);
        }

        recentlyDeletedCategory = null;
        recentlyDeletedCategoryId = null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category restored successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring category: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoriesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No categories available."),
            );
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final String categoryId = category.id;
              final String title = category['title'];
              final String image = category['image'];

              return Dismissible(
                key: Key(categoryId),
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
                  deleteCategory(categoryId, title);
                },
                child: ListTile(
                  leading: Image.network(
                    image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(title),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
