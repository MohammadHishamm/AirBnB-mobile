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
  String selectedCategory = ''; // Default to empty string (fetch all places)

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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    // Pass selected category to DisplayPlace
                    DisplayPlace(
                        displayCategory:
                            selectedCategory), // Pass the selected category
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
          // Adding "All" category at the beginning of the list
          var categories = [
            {
              'title': 'All',
              'image': 'https://cdn-icons-png.flaticon.com/512/443/443635.png'
            }, // Add the "All" category
            ...streamSnapshot.data!.docs
                .map((doc) => {
                      'title': doc['title'],
                      'image': doc['image'],
                    })
                .toList()
          ];

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
                  itemCount: categories.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          selectedCategory = category['title'] == 'All'
                              ? '' // If "All" is selected, set selectedCategory to empty
                              : category['title'];
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
                                category[
                                    'image'], // Use network image from the list
                                color: isSelected
                                    ? Colors.pinkAccent
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors
                                            .black45), // Icon color based on selection
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error,
                                      color: Colors
                                          .red); // Display an error icon if the image fails to load
                                },
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              category['title'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.pinkAccent
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
