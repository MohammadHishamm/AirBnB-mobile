import 'package:airbnb/Components/my_icon_button.dart';
import 'package:airbnb/components/adaptive_image.dart';

import 'package:airbnb/components/location_in_map.dart';
import 'package:airbnb/provider/favorite_provider.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airbnb/provider/Theme_provider.dart';
import 'package:airbnb/view/PaymentScreen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Size size = MediaQuery.of(context).size;
    final provider = FavoriteProvider.of(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // detail image, back button, share, and favorite button
            detailImageandIcon(size, context, provider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place['title'],
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "Room in ${widget.place['address']}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  Text(
                    widget.place['bedAndBathroom'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            widget.place["isActive"] == true
                ? ratingAndStarTrue(textColor)
                : ratingAndStarFalse(textColor),
            SizedBox(height: size.height * 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  placePropertyList(
                    size,
                    "https://static.vecteezy.com/system/resources/previews/018/923/486/original/diamond-symbol-icon-png.png",
                    "This is a rare find",
                    "${widget.place['vendor']}'s place is usually fully booked.",
                    textColor,
                  ),
                  const Divider(),
                  placePropertyList(
                    size,
                    widget.place['vendor'],
                    "Stay with ${widget.place['vendor']}",
                    "Superhost . ${widget.place['yearOfHostin']} years hosting",
                    textColor,
                  ),
                  const Divider(),
                  placePropertyList(
                    size,
                    "https://cdn-icons-png.flaticon.com/512/6192/6192020.png",
                    "Room in a rental unit",
                    "Your own room in a home, plus access\nto shared spaces.",
                    textColor,
                  ),
                  placePropertyList(
                    size,
                    "https://cdn0.iconfinder.com/data/icons/co-working/512/coworking-sharing-17-512.png",
                    "Shared common spaces",
                    "You'll share parts of the home with the host.",
                    textColor,
                  ),
                  placePropertyList(
                    size,
                    "https://img.pikbest.com/element_our/20230223/bg/102f90fb4dec6.png!w700wp",
                    "Shared bathroom",
                    "You'll share the bathroom with others.",
                    textColor,
                  ),
                  const Divider(),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "About this place",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  const Divider(),
                  Text(
                    "Where you'll be",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    widget.place['address'],
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    width: size.width,
                    child: LocationInMap(
                      place: widget.place,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: priceAndReserve(size, textColor, themeProvider),
    );
  }

  Container priceAndReserve(
      Size size, Color textColor, ThemeProvider themeProvider) {
    return Container(
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: "\$${widget.place['price']} ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 18,
                  ),
                  children: [
                    TextSpan(
                      text: "night",
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.place['date'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(
            width: size.width * 0.3,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 35,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(15),
            ),
            child: GestureDetector(
              onTap: () {
                // Navigate to the PaymentScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      price: widget.place['price'],
                      title: widget.place['title'],
                      placeid: widget.place.id,
                    ),
                  ),
                );
              },
              child: const Text(
                "Reserve",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding placePropertyList(
      Size size, image, title, subtitle, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const Divider(),
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(image),
            radius: 29,
          ),
          SizedBox(
            width: size.width * 0.05,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: size.width * 0.0346,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding ratingAndStarFalse(Color textColor) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.star),
            const SizedBox(width: 5),
          ],
        ),
      );

  Container ratingAndStarTrue(Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Image.network(
                "https://wallpapers.com/images/hd/golden-laurel-wreathon-teal-background-k5791qxis5rtcx7w-k5791qxis5rtcx7w.png",
                height: 50,
                width: 130,
                color: Colors.amber,
              ),
              const Positioned(
                left: 35,
                child: Text(
                  "Guest\nfavorite",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Stack detailImageandIcon(Size size, BuildContext context, provider) {
    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.35,
          child: AnotherCarousel(
            images: widget.place['imageUrls']
                .map<Widget>((url) => AdaptiveImage(
                      imageSource: url,
                      fit: BoxFit.cover,
                    ))
                .toList(),
            showIndicator: false,
            dotBgColor: Colors.transparent,
            onImageChange: (p0, p1) {
              setState(() {
                currentIndex = p1;
              });
            },
            autoplay: true,
            boxFit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 10,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.black45),
            child: Text(
              "${currentIndex + 1} / ${widget.place['imageUrls'].length}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          top: 25,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const MyIconButton(
                    icon: Icons.arrow_back_ios_new,
                  ),
                ),
                SizedBox(
                  width: size.width * 0.55,
                ),
                const MyIconButton(icon: Icons.share_outlined),
                const SizedBox(width: 20),
                // after this all let's make favorite button function by using provider
                InkWell(
                  onTap: () {
                    provider.toggleFavorite(widget.place, context);
                  },
                  child: MyIconButton(
                    icon: provider.isExist(widget.place)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor: provider.isExist(widget.place)
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
