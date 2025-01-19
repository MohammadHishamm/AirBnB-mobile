import 'package:airbnb/view/Login_screen.dart';
import 'package:airbnb/view/accessibility_screen.dart';
import 'package:airbnb/view/add_place_screen.dart';
import 'package:airbnb/view/view_place_screen.dart';
import 'package:airbnb/view/detailed_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:airbnb/Authentication/google_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:airbnb/view/add_category.dart';
import 'package:airbnb/view/view_category.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userType;

  @override
  void initState() {
    super.initState();
    _fetchUserType();
  }

  Future<void> _fetchUserType() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userType = userDoc['userType'];
        });
      }
    } catch (e) {
      print('Error fetching user type: $e');
    }
  }






  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Icon(
                      Icons.notifications_outlined,
                      size: 35,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.black54,
                      backgroundImage: NetworkImage(
                          "${FirebaseAuth.instance.currentUser!.photoURL}"),
                    ),
                    SizedBox(width: size.width * 0.06),
                    Text.rich(
                      TextSpan(
                        text:
                            "${FirebaseAuth.instance.currentUser!.displayName}\n",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        children: [
                          TextSpan(
                            text: "Show profile",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ShowProfileScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ShowProfileScreen()),
                        );
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Airbnb your place\n",
                            style: TextStyle(
                              height: 2.5,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "It's simple to get set up and \nstart earning.",
                                style: TextStyle(
                                  height: 1.2,
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Image.network(
                          "https://static.vecteezy.com/system/resources/previews/034/950/530/non_2x/ai-generated-small-house-with-flowers-on-transparent-background-image-png.png",
                          height: 140,
                          width: 135,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 15),
                Text(
                  "Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                profileInfo(context, Icons.payments_outlined, "Payments"),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccessibilityScreen()),
                    );
                  },
                  child: profileInfo(
                      context, Icons.settings_outlined, "Accessibility"),
                ),
                profileInfo(
                    context, Icons.notifications_outlined, "Notifications"),
                const SizedBox(height: 15),
                Text(
                  "Hosting",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPlaceScreen()),
                    );
                  },
                  child: profileInfo(
                      context, Icons.add_home_outlined, "List your space"),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DisplayUserPlaces()),
                    );
                  },
                  child: profileInfo(
                      context, Icons.view_compact, "View your space"),
                ),
                 if (userType == 'admin') ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCategoryPage()),
                    );
                  },
                  
                  child: profileInfo(

                      context, Icons.category_rounded, "Add category"),
                ),
                 
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoriesPage()),
                    );
                  },
                  child: profileInfo(
                      context, Icons.view_comfy_alt_rounded, "View categories"),
                ),
                 ],
                profileInfo(
                    context, Icons.home_outlined, "Learn about hosting"),
                const SizedBox(height: 15),
                Text(
                  "Support",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 25),
                profileInfo(
                    context, Icons.help_outline, "Visit the Help Center"),
                profileInfo(context, Icons.ac_unit, "How Airbnb works"),
                profileInfo(context, Icons.edit_outlined, "Give us feedback"),
                const SizedBox(height: 15),
                Text(
                  "Legal",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 25),
                profileInfo(
                    context, Icons.menu_book_outlined, "Terms of Service"),
                profileInfo(
                    context, Icons.menu_book_outlined, "Privacy Policy"),
                profileInfo(
                    context, Icons.menu_book_outlined, "Open source licenses"),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuthServices().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    } catch (e) {
                      print('Error during logout: $e');
                    }
                  },
                  child: Text(
                    "Log out",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 20),
                Text(
                  "Version 24.34 (28004615)",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Padding profileInfo(BuildContext context, IconData icon, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 35,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 20),
              Text(
                name,
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
