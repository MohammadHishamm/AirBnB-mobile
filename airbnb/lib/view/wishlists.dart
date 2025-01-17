import 'package:airbnb/components/adaptive_image.dart';
import 'package:airbnb/provider/favorite_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:airbnb/view/place_details_screen.dart';

class Wishlists extends StatefulWidget {
  const Wishlists({super.key});

  @override
  State<Wishlists> createState() => _WishlistsState();
}

class _WishlistsState extends State<Wishlists> {
  @override
  void initState() {
    super.initState();
    // Load the favorites for the current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = FavoriteProvider.of(context, listen: false);
      provider.loadFavorite(); // Explicitly load favorites
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favorites;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Use theme for background color
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 35),
                Text(
                  "Wishlists",
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 5),
                favoriteItems.isEmpty
                    ? Text(
                        "No Favorites items yet",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.68,
                        child: GridView.builder(
                          itemCount: favoriteItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            String favorite = favoriteItems[index];
                            return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("myAppCollection")
                                    .doc(favorite)
                                    .get(),
                                builder: (context, snapShot) {
                                  if (snapShot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapShot.hasData ||
                                      snapShot.data == null) {
                                    return const Center(
                                      child: Text("Error loading favorites"),
                                    );
                                  }
                                  var favoriteItem = snapShot.data!;
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate to the detail screen and pass the favorite item data
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PlaceDetailScreen(
                                            place:
                                                favoriteItem, // Pass the favorite item
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        // image of favorite items
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: AdaptiveImage(
                                              imageSource:
                                                  favoriteItem['image'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        // favorite icon in the top right corner
                                        const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),
                                        ),
                                        // title of favorite items
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              favoriteItem['title'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
