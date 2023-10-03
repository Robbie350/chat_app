// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:chat_app/components/comment_button.dart';
import 'package:chat_app/components/delete_button.dart';
import 'package:chat_app/components/like_button.dart';
import 'package:chat_app/helper/helper_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'comment.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final String time;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // comment text controller

  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // Access the doc in Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is liked add the user email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      // if the post is now unliked remove the user email from 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  // add a comment method
  void addComment(String commentText) {
    // write the comment to the firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'CommentText': commentText,
      'CommentedBy': currentUser.email,
      'CommentTime':
          Timestamp.now(), // remember the format this when displaying
    });
  }

  // show a dialog to the user to add the comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Comment'),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: 'Write a comment....'),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear the controller
              _commentTextController.clear();
            },
            child: Text('Cancel'),
          ),
          // post button
          TextButton(
            onPressed: () {
              // add the comment
              addComment(_commentTextController.text);

              // pop box
              Navigator.pop(context);

              // clear the controller
              _commentTextController.clear();
            },
            child: Text('Post'),
          ),
        ],
      ),
    );
  }

  // delete Post method
  void deletePost() {
    // show a dialog box for asking confirmation before deleting the post
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete your post?'),
        actions: [
          // CANCEL BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Calcel'),
          ),

          // DELETE BUTTON
          TextButton(
            onPressed: () async {
              // delete the comments from firestore first
              //(if only you delete the post comments will still be there in firestore)
              final commentDocs = await FirebaseFirestore.instance
                  .collection('User Posts')
                  .doc(widget.postId)
                  .collection('Comments')
                  .get();
              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection('User Posts')
                    .doc(widget.postId)
                    .collection('Comments')
                    .doc(doc.id)
                    .delete();
              }

              // delete the wall post
              FirebaseFirestore.instance
                  .collection('User Posts')
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print('post deleted'))
                  .catchError(
                    (error) => print('failed to delete : $error'),
                  );

              // dismiss the dialog box
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // wall post
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group of text (message and user email)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // message
                  Text(widget.message),
                  const SizedBox(height: 5),
                  // user
                  // user, time,
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        '~',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              //  delete button
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),
          const SizedBox(height: 20),
          //  buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LIKE
              Column(
                children: [
                  // like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),

                  const SizedBox(height: 5),

                  // like count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // COMMENT
              Column(
                children: [
                  // comment button
                  CommentButton(onTap: showCommentDialog),

                  const SizedBox(height: 5),

                  // comment count
                  Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // display comments under the posts
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .doc(widget.postId)
                .collection('Comments')
                .orderBy('CommentTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // show a loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true, // when nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  // get the comment from firebase
                  final commentData = doc.data() as Map<String, dynamic>;

                  // return the comment
                  return Comment(
                    text: commentData['CommentText'],
                    user: commentData['CommentedBy'],
                    time: formatDate(commentData['CommentTime']),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
