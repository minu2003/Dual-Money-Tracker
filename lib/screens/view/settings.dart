import 'package:flutter/material.dart';
import 'package:money_app/theme/theme_provider.dart';
import 'package:money_app/screens/view/forgot_password_screen.dart';
import 'package:money_app/screens/view/profile_screen.dart';
import 'package:money_app/screens/view/update_password_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isNotificationOn = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings", style: TextStyle(
            fontSize: 25
          ),),
        ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only( left: 30, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text("Notification"),
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(value: isNotificationOn, onChanged: (bool value){
                        setState(() {
                          isNotificationOn = value;
                        });
                      },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                    onTap: (){},
                  ),
                  SizedBox(height: 10,),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text("Profile"),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => edit_profile())
                      );
                    },
                  ),
                  SizedBox(height: 10,),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text("Change Password"),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ForgotPasswordScreen())
                      );
                    },
                  ),
                  SizedBox(height: 10,),
                  ListTile(
                    leading: const Icon(Icons.format_paint),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text("Theme"),
                    ),
                    onTap: () {
                      theme_provider(context);
                    },

                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
