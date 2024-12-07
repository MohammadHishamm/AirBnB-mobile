import 'package:airbnb/model/category.dart';
import 'package:airbnb/model/place_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
      apiKey: "AIzaSyCGgQ3zjP46P_Bhb1y-WPzQpDvtLY_oPA0",
      appId: "1:356192158933:android:f802fa34df0a8434edce5c",
      messagingSenderId: "356192158933",
      projectId: "airbnb-41b07",
    ),
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child:
              ElevatedButton(onPressed: saveCategoryItems, child: Text("data")),
        ),
      ),
    );
  }
}
