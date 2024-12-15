import 'package:airbnb/Provider/favorite_provider.dart';
import 'package:airbnb/view/Login_screen.dart';
import 'package:airbnb/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
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
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: LoginScreen(),
    // );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            // keep user login until logout

            StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const AppMainScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
