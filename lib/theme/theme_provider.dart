import 'package:flutter/material.dart';

void theme_provider(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.circle_outlined),
              title: Text("System Default"),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.light_mode_outlined),
              title: Text("Light Theme"),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined),
              title: Text("Dark Theme"),
              onTap: () {

              },
            ),
          ],
        ),
      );
    },
  );
}
