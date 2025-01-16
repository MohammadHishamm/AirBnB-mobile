import 'package:airbnb/Authentication/google_auth.dart';
import 'package:airbnb/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark; // Detecting the theme

    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : Colors.white, // Dynamic background color
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Log in or sign up",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black, // Dynamic text color
                  ),
                ),
              ),
              const Divider(color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Airbnb",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black, // Dynamic text color
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Phone number field
                    phoneNumberField(size, isDarkMode),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text:
                            "We'll call or text you to confirm your number. Standard message and data rates apply. ",
                        style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.white70 : Colors.black),
                        children: [
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: isDarkMode ? Colors.white : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.pink,
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppMainScreen(),
                            ),
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.transparent,
                              color: isDarkMode
                                  ? Colors.black
                                  : Colors.white, // Dynamic text color
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.026),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: isDarkMode
                                    ? Colors.white30
                                    : Colors.black26)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("or", style: TextStyle(fontSize: 18)),
                        ),
                        Expanded(
                            child: Divider(
                                color: isDarkMode
                                    ? Colors.white30
                                    : Colors.black26)),
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),
                    socialIcons(
                      size,
                      Icons.facebook,
                      "Continue with Facebook",
                      Colors.blue,
                      30,
                      isDarkMode,
                    ),
                    InkWell(
                      onTap: () async {
                        print('Attempting to sign in...');
                        await FirebaseAuthServices().signInWithGoogle();

                        try {
                          final currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser != null) {
                            print('User signed in: ${currentUser.email}');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppMainScreen(),
                              ),
                            );
                          } else {
                            print('No user signed in');
                            // Handle the case where no user is signed in
                          }
                        } catch (e) {
                          print('Error during sign-in process: $e');
                        }
                      },
                      child: socialIcons(
                        size,
                        FontAwesomeIcons.google,
                        "Continue with Google",
                        Colors.pink,
                        27,
                        isDarkMode,
                      ),
                    ),
                    socialIcons(
                      size,
                      Icons.apple,
                      "Continue with Apple",
                      Colors.black,
                      30,
                      isDarkMode,
                    ),
                    socialIcons(
                      size,
                      Icons.email_outlined,
                      "Continue with email",
                      Colors.black,
                      30,
                      isDarkMode,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Need help?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Dynamic text color
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding socialIcons(
      Size size, icon, name, color, double iconSize, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? Colors.white30
                : Colors.black26, // Dynamic border color
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: size.width * 0.05),
            Icon(icon, color: color, size: iconSize),
            SizedBox(width: size.width * 0.18),
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? Colors.white
                    : Colors.black, // Dynamic text color
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Container phoneNumberField(Size size, bool isDarkMode) {
    return Container(
      width: size.width,
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(
            color: isDarkMode
                ? Colors.white30
                : Colors.black45), // Dynamic border color
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10, left: 10, top: 8),
            child:
                Text("Country/Region", style: TextStyle(color: Colors.black45)),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Phone number",
                hintStyle: TextStyle(fontSize: 18, color: Colors.black45),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
