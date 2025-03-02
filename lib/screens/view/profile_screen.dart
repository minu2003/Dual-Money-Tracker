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
  String? profileImageUrl;

  void handleAccountChange(String account) {
    setState(() {
      currentAccount = account;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userdata = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = userdata.data()?['username'] ?? "User";
        userEmail = userdata.data()?['email'] ?? user.email ?? "No Email Found";
        profileImageUrl = userdata.data()?['profileImageUrl'];

        DateTime joinDate = user.metadata.creationTime ?? DateTime.now();
        joinDateFormatted = "${joinDate.month}/${joinDate.day}/${joinDate.year}";
      });
    }
  }

  void _showProfileImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: profileImageUrl != null
                        ? Image.network(
                      profileImageUrl!,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.person, size: 100, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            // Back Button
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => Wrap(
        children: profileImageUrl == null
            ? [
          ListTile(
            leading: const Icon(Icons.add_a_photo),
            title: const Text("Add Image"),
            onTap: () {
              Navigator.pop(context);
              // Implement image upload logic here
            },
          ),
        ]
            : [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("View Image"),
            onTap: () {
              Navigator.pop(context);
              _showProfileImage(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Image"),
            onTap: () {
              Navigator.pop(context);
              // Implement image edit logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Remove Image"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                profileImageUrl = null;
              });
            },
          ),
        ],
      ),
    );
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
            Image.asset("assets/Logo.png", height: 50),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                    child: profileImageUrl != null
                        ? GestureDetector(
                      onTap: () => _showProfileImage(context),
                      child: ClipOval(
                        child: Image.network(
                          profileImageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : const Icon(Icons.person, size: 50, color: Colors.black54),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _showImageOptions(context),
                      child: const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 18,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 45, top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Name:",
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
            ),
          ],
        ),
      ),
    );
  }
}
