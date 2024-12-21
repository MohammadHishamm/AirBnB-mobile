import 'package:airbnb/Components/display_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // collection for category
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection("AppCategory");

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Fetch current theme settings
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Dynamically set based on theme
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Let's fetch list of category items from Firebase
            listOfCategoryItems(size, isDarkMode),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    // Display the place items
                    DisplayPlace(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Optional: Floating action button or other features can be added here
    );
  }

  // Function to build a list of categories from Firebase
  StreamBuilder<QuerySnapshot<Object?>> listOfCategoryItems(
      Size size, bool isDarkMode) {
    return StreamBuilder(
      stream: categoryCollection.snapshots(),
      builder: (context, streamSnapshot) {
        if (streamSnapshot.hasData) {
          return Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 80,
                child: Divider(
                  color: Colors.black12,
                ),
              ),
              SizedBox(
                height: size.height * 0.12,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: streamSnapshot.data!.docs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 20,
                          right: 20,
                          left: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: isDarkMode
                              ? Colors.black45
                              : Colors.white, // Background color based on theme
                        ),
                        child: Column(
                          children: [
                            Container(
                              height:
                                  48, // Increased icon size for consistent layout
                              width:
                                  48, // Icon size remains large for consistency
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.network(
                                streamSnapshot.data!.docs[index]['image'],
                                color: isSelected
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors
                                            .black45), // Icon color based on selection
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              streamSnapshot.data!.docs[index]['title'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? (isDarkMode
                                        ? Colors.white
                                        : Colors
                                            .black) // Text color when selected
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors
                                            .black45), // Text color when not selected
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 3,
                              width: 50,
                              color: isSelected
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : Colors
                                      .transparent, // Underline color when selected
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
