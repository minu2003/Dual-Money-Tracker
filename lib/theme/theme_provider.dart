import 'package:flutter/material.dart';
import 'package:money_app/theme/theme_mode_provider.dart';
import 'package:provider/provider.dart';

void theme_provider(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final themeProvider = Provider.of<ThemeModeProvider>(context, listen: false);
      return AlertDialog(
        title: Text("Select Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.circle_outlined),
              title: Text("System Default"),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.light_mode_outlined),
              title: Text("Light Theme"),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined),
              title: Text("Dark Theme"),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
