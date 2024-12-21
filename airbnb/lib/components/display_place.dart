import 'package:airbnb/provider/favorite_provider.dart';
import 'package:airbnb/view/place_details_screen.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayPlace extends StatefulWidget {
  final String displayCategory; // Add this field to store the selected category

  const DisplayPlace({super.key, required this.displayCategory});
  @override
  State<DisplayPlace> createState() => _DisplayPlaceState();
}

class _DisplayPlaceState extends State<DisplayPlace> {
  // collection for place items
  final CollectionReference placeCollection =
      FirebaseFirestore.instance.collection("myAppCollection");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = FavoriteProvider.of(context);

    // Fetch current theme settings to adjust colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: widget.displayCategory.isEmpty
          ? placeCollection.snapshots() // If no category selected, fetch all places
          : placeCollection
              .where("category", isEqualTo: widget.displayCategory) // Filter by category if selected
              .snapshots(),
      builder: (context, streamSnapshot) {
        if (streamSnapshot.hasData) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: streamSnapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final DocumentSnapshot place = streamSnapshot.data!.docs[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailScreen(place: place),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: SizedBox(
                              height: 375,
                              width: double.infinity,
                              child: AnotherCarousel(
                                images: place['imageUrls'].map((url) {
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    placeholder: (context, url) =>
                                        Transform.scale(
                                      scale: 0.3, // Scale the loading indicator
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      print(
                                          'Failed to load image: $url, error: $error');
                                      return const Icon(Icons
                                          .error); // Placeholder error icon
                                    },
                                    fit: BoxFit.cover,
                                  );
                                }).toList(),
                                dotSize: 6,
                                indicatorBgPadding: 5,
                                dotBgColor: Colors.transparent,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 15,
                            right: 15,
                            child: Row(
                              children: [
                                place['isActive'] == true
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.black54
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                        ),
                                      )
                                    : SizedBox(width: size.width * 0.03),
                                const Spacer(),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.favorite_outline_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        provider.toggleFavorite(place, context);
                                      },
                                      child: Icon(
                                        Icons.favorite,
                                        size: 30,
                                        color: provider.isExist(place)
                                            ? Colors.red
                                            : isDarkMode
                                                ? Colors.white70
                                                : Colors
                                                    .black54, // Dynamic favorite icon color
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Text(
                            place['address'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black, // Dynamic text color
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.star,
                            color: isDarkMode
                                ? Colors.yellowAccent
                                : Colors.amber, // Dynamic star color
                          ),
                          const SizedBox(width: 5),
                          Text(
                            place['rating'].toString(),
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black, // Dynamic text color
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Stay with ${place['vendor']} . ${place['vendorProfession']}",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.black54, // Dynamic text color
                          fontSize: 16.5,
                        ),
                      ),
                      Text(
                        place['date'],
                        style: TextStyle(
                          fontSize: 16.5,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.black54, // Dynamic text color
                        ),
                      ),
                      SizedBox(height: size.height * 0.007),
                      RichText(
                        text: TextSpan(
                          text: "\$${place['price']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black, // Dynamic price color
                            fontSize: 16,
                          ),
                          children: const [
                            TextSpan(
                              text: "night",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.025),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Positioned vendorProfile(QueryDocumentSnapshot<Object?> place) {
  //   return Positioned(
  //     bottom: 11,
  //     left: 10,
  //     child: Stack(
  //       children: [
  //         const ClipRRect(
  //           borderRadius: BorderRadius.only(
  //             topRight: Radius.circular(15),
  //             bottomRight: Radius.circular(15),
  //           ),
  //         ),
  //         Positioned(
  //           top: 10,
  //           left: 10,
  //           child: CircleAvatar(
  //             backgroundImage: NetworkImage(
  //               place['vendorProfile'],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
