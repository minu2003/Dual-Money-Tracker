import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Authentication/sign_in.dart';
import '../../components/AccountSwitcher.dart';

class edit_profile extends StatefulWidget {
  const edit_profile({super.key});

  @override
  State<edit_profile> createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  String userName = "Name";
  String userEmail = "Email";
  String joinDateFormatted = "Loading...";
  String currentAccount = 'Personal';

  void handleAccountChange(String account) {
    setState(() {
      currentAccount = account;
    });
    print("Switched to: $account");
  }
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userdata = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      print("Firestore Data: ${userdata.data()}");
      setState(() {
        userName = userdata.data()?['username'] ?? "User";
        userEmail = userdata.data()?['email'] ?? user.email ?? "No Email Found";
        DateTime joinDate = user.metadata.creationTime ?? DateTime.now();

        joinDateFormatted = "${joinDate.month}/${joinDate.day}/${joinDate.year}";
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.blue),),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const login()),
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/dualLogo.png",
              height: 50,
            ),
          ],
        ),
        actions: [
          AccountSwitcher(onAccountChanged: handleAccountChange),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    userName, // Display the retrieved name here
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 45, top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userName,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Email:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    const SizedBox(height: 20),
                    // Join Date
                    Text(
                      "Joined Date:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      joinDateFormatted,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    SizedBox(height: 200,),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                      onTap: () => _logout(context),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
