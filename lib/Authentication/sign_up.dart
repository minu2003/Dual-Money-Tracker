import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_app/Authentication/sign_in.dart';

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _passwordsMatch = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _passwordsMatch = false;
        });
        return;
      } else {
        setState(() {
          _passwordsMatch = true;
        });
      }
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': _userNameController.text,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: const Text(
            "Hello!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Form(
            key: _formKey,
            child: Container(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 100,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30), topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              cursorColor: Colors.blue,
                              controller: _userNameController,
                              validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              cursorColor: Colors.blue,
                              controller: _emailController,
                              validator: (value) => value!.isEmpty ? 'Enter a valid email' : null,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              cursorColor: Colors.blue,
                              controller: _passwordController,
                              validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextFormField(
                                  cursorColor: Colors.blue,
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                              ),
                              if (!_passwordsMatch)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Center(
                                    child: Text(
                                      "Passwords do not match",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black),
                              child: const Text(
                                "Sign Up",
                                style:
                                TextStyle(color: Colors.white, fontSize: 15),
                              ),),),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset("assets/google1.png", height: 40),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: (){},
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset("assets/facebook1.png", height: 40),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an Account?",
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => const login() )
                                  );
                                } ,
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Image.asset(
                            "assets/dual-Logo-white.png",
                            height: 60,
                            width: 150,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );;
  }
}

