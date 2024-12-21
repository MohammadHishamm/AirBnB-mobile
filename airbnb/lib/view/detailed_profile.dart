import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShowProfileScreen extends StatelessWidget {
  const ShowProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the user details from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Dynamic background color
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .appBarTheme
            .backgroundColor, // Dynamic AppBar color
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context)
                .iconTheme
                .color, // Dynamically fetch icon color based on theme
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Details',
          style: TextStyle(
            color: Theme.of(context)
                .appBarTheme
                .titleTextStyle
                ?.color, // Dynamic title color
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context)
                        .cardColor, // Dynamic background color for the avatar
                    backgroundImage: NetworkImage(
                      user?.photoURL ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? "User Name",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color, // Dynamic color
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user?.email ?? "No email provided",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color, // Dynamic color
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Personal Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color, // Dynamic color
              ),
            ),
            const SizedBox(height: 15),
            profileDetailTile(
                Icons.person, "Name", user?.displayName ?? "N/A", context),
            profileDetailTile(
                Icons.email, "Email", user?.email ?? "N/A", context),
            profileDetailTile(
                Icons.phone, "Phone", user?.phoneNumber ?? "Not set", context),
          ],
        ),
      ),
    );
  }

  // Helper function to create styled tiles for profile information
  Widget profileDetailTile(
      IconData icon, String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: Theme.of(context)
                .iconTheme
                .color, // Dynamic color based on theme
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color, // Dynamic color
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Dynamic color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
