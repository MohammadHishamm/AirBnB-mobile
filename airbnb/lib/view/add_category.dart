import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:airbnb/model/category_model.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final CollectionReference ref =
      FirebaseFirestore.instance.collection("AppCategory");
  Future<void> addCategory() async {
    String title = _titleController.text.trim();
    String image = _imageController.text.trim();

    if (title.isEmpty || image.isEmpty) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Title and Image are required!")),
      );
      return;
    }

    
    QuerySnapshot snapshot = await ref.where('title', isEqualTo: title).get();

    if (snapshot.docs.isNotEmpty) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Category with this title already exists!")),
      );
      return;
    }

    
    final String id =
        DateTime.now().toIso8601String() + Random().nextInt(1000).toString();
    final Category newCategory = Category(title: title, image: image);
    await ref.doc(id).set(newCategory.toMap());

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Category added successfully!")),
    );

    
    _titleController.clear();
    _imageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Category Title"),
            ),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(labelText: "Category Image URL"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addCategory,
              child: Text("Add Category"),
            ),
          ],
        ),
      ),
    );
  }
}
