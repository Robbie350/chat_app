// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chat_app/components/text_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // get the user email
  final currenUser = FirebaseAuth.instance.currentUser!;
  // all users
  final userCollection = FirebaseFirestore.instance.collection('Users');

  // edit field
  Future<void> editField(String field) async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit $field',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancel button
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel the changes',
                style: TextStyle(color: Colors.white),
              )),

          //save button
          TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: Text(
                'Save the changes',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
    // update the fire store

    if (newValue.trim().isNotEmpty) {
      // only update if theere is smth in the text field
      await userCollection.doc(currenUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Profile Page',
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currenUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          // get a user data
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 50),
                // profile pic
                const Icon(
                  Icons.person,
                  size: 72,
                ),
                const SizedBox(height: 10),

                // user email
                Text(
                  currenUser.email.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 50),

                // user details
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                // username
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                // bio
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'user bio',
                  onPressed: () => editField('bio'),
                ),

                // user posts
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
