// ignore_for_file: prefer_const_constructors

import 'package:chat_app/components/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_button.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // sign Up method

  void signUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    // make sure that passwords match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // pop the loading circle
      Navigator.pop(context);
      // show the error to the user
      displayMessage('Passwords do not match');
      return;
    }
    // try creating the user
    try {
      // create a user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
      // after creating the user, create a new document in the cloud firestore Users
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email!)
          .set({
        'username': emailTextController.text.split('@')[0], // initial username
        'bio': 'Empty bio....', // initilly it is empty
        // add new fields if you want.
      });

      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      // pop loadin circle
      Navigator.pop(context);
      // show error to user
      displayMessage(e.code);
    }
  }

  // display a dialogu message
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50),

                // welcome back message
                Text(
                  'Lets create an account for you.',
                  style: TextStyle(
                    color: Colors.grey[650],
                  ),
                ),

                const SizedBox(height: 25),

                // email text field
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // password text field
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // conform password text field
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // sign Up button
                MyButton(onTap: signUp, text: 'Sign Up'),

                // go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.grey[650],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login Now.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
