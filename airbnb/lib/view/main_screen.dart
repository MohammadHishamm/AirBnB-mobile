import 'package:airbnb/view/explore_screen.dart';
import 'package:airbnb/view/message.dart';
import 'package:airbnb/view/profile_page.dart';
import 'package:airbnb/view/wishlists.dart';
import 'package:flutter/material.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;

  @override
  void initState() {
    page = [
      const ExploreScreen(),
      const Wishlists(),
      const Scaffold(),
      const MessagesScreen(title: "Chat with GPT"),
      const ProfilePage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : Colors.white, // Dynamic background color
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode
            ? Colors.black
            : Colors.white, // Dynamic background color
        elevation: 5,
        iconSize: 32,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: isDarkMode
            ? Colors.white70
            : Colors.black45, // Dynamic unselected item color
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              isDarkMode ? Colors.white : Colors.black, // Dynamic label color
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? Colors.white70
              : Colors.black45, // Dynamic label color
        ),
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.network(
              "https://cdn3.iconfinder.com/data/icons/feather-5/24/search-512.png",
              height: 30,
              color: selectedIndex == 0
                  ? Colors.pinkAccent
                  : (isDarkMode
                      ? Colors.white70
                      : Colors.black45), // Dynamic icon color
            ),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              color: selectedIndex == 1
                  ? Colors.pinkAccent
                  : (isDarkMode
                      ? Colors.white70
                      : Colors.black45), // Dynamic icon color
            ),
            label: "Wishlists",
          ),
          BottomNavigationBarItem(
            icon: Image.network(
              "https://cdn-icons-png.flaticon.com/512/2111/2111307.png",
              height: 30,
              color: selectedIndex == 2
                  ? Colors.pinkAccent
                  : (isDarkMode
                      ? Colors.white70
                      : Colors.black45), // Dynamic icon color
            ),
            label: "Trip",
          ),
          BottomNavigationBarItem(
            icon: Image.network(
              "https://static.vecteezy.com/system/resources/thumbnails/014/441/006/small_2x/chat-message-thin-line-icon-social-icon-set-png.png",
              height: 30,
              color: selectedIndex == 3
                  ? Colors.pinkAccent
                  : (isDarkMode
                      ? Colors.white70
                      : Colors.black45), // Dynamic icon color
            ),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Image.network(
              "https://cdn-icons-png.flaticon.com/512/1144/1144760.png",
              height: 30,
              color: selectedIndex == 4
                  ? Colors.pinkAccent
                  : (isDarkMode
                      ? Colors.white70
                      : Colors.black45), // Dynamic icon color
            ),
            label: "Profile",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }
}
