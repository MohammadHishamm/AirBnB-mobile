import 'package:airbnb/provider/Theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme Toggle"),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SwitchListTile(
            title: const Text(
              "Dark Mode",
              style: TextStyle(fontSize: 28),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          );
        },
      ),
    );
  }
}
