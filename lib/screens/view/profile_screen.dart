import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            Image.asset(
              "assets/Logo.png",
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
                    child: const Icon(Icons.person, size: 40),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    userName, // Display the retrieved name here
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Email:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    // Join Date
                    const Text(
                      "Joined Date:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      joinDateFormatted,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
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
