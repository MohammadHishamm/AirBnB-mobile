import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final CollectionReference ref =
      FirebaseFirestore.instance.collection("AppCategory");
// function
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
