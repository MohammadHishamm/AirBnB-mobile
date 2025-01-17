import 'package:airbnb/provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:airbnb/provider/Theme_provider.dart';
import 'package:airbnb/view/Login_screen.dart';
import 'package:airbnb/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable all orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCGgQ3zjP46P_Bhb1y-WPzQpDvtLY_oPA0",
      appId: "1:356192158933:android:f802fa34df0a8434edce5c",
      messagingSenderId: "356192158933",
      projectId: "airbnb-41b07",
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDarkMode
                ? ThemeData.dark().copyWith(
                    scaffoldBackgroundColor: Colors.black,
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.black,
                      titleTextStyle: TextStyle(color: Colors.white),
                    ),
                    textTheme: const TextTheme(
                      bodyLarge: TextStyle(color: Colors.white),
                      bodyMedium: TextStyle(color: Colors.white),
                      titleMedium: TextStyle(color: Colors.white),
                    ),
                  )
                : ThemeData.light().copyWith(
                    scaffoldBackgroundColor: Colors.white,
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.white,
                      titleTextStyle: TextStyle(color: Colors.black),
                    ),
                    textTheme: const TextTheme(
                      bodyLarge: TextStyle(color: Colors.black),
                      bodyMedium: TextStyle(color: Colors.black),
                      titleMedium: TextStyle(color: Colors.black),
                    ),
                  ),
            builder: (context, child) {
              // Only apply modifications in landscape mode
              return OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return MediaQuery(
                      // Only modify layout properties in landscape
                      data: MediaQuery.of(context).copyWith(
                        // Maintain text size but adjust padding for landscape
                        padding: MediaQuery.of(context).padding.copyWith(
                              left: 20.0,
                              right: 20.0,
                            ),
                      ),
                      child: child!,
                    );
                  }
                  // Return unchanged child in portrait mode
                  return child!;
                },
              );
            },
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const AppMainScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
