// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'package:chat_app/components/drawer.dart';
import 'package:chat_app/components/text_field.dart';
import 'package:chat_app/components/wall_post.dart';
import 'package:chat_app/helper/helper_method.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user
  final currenUser = FirebaseAuth.instance.currentUser!;

  // text controller

  final textController = TextEditingController();

  // sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // post message
  void postMessage() {
    // only post if there is smth in the textfield
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection('User Posts').add({
        'User Email': currenUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    // clear the text field
    setState(() {
      textController.clear();
    });
  }
  // go to profile page method

  void goToProfilePage() {
    // pop the menu drawer
    Navigator.pop(context);

    // go to the new page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Center(
          child: Text(
            'The Wall',
          ),
        ),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(children: [
          // the wall
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .orderBy(
                  'TimeStamp',
                  descending: false,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    // get the message first
                    final post = snapshot.data!.docs[index];
                    return WallPost(
                      message: post['Message'],
                      user: post['User Email'],
                      postId: post.id,
                      likes: List<String>.from(post['Likes'] ?? []),
                      time: formatDate(post['TimeStamp']),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error' + snapshot.error.toString(),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )),

          // post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                // text field
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: 'Write some post on the Wall',
                    obscureText: false,
                  ),
                ),

                // post button
                IconButton(
                  onPressed: postMessage,
                  icon: const Icon(Icons.arrow_circle_up),
                ),
              ],
            ),
          ),

          // logged in as
          Text(
            'Logged in as: ' + currenUser.email!,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }
}
