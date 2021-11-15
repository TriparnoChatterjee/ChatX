import 'package:firebase_auth/firebase_auth.dart';

import 'message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapShot) {
        if (chatSnapShot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapShot.data!.docs;

        // chatDocs.reversed;
        return FirebaseAuth.instance.currentUser == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                reverse: true,
                itemBuilder: (ctx, index) => MessageBubble(
                    chatDocs[index]['text'],
                    chatDocs[index]["userId"] ==
                        FirebaseAuth.instance.currentUser!.uid,
                    // chatDocs[index]['userId'],
                    chatDocs[index]['username'],
                    chatDocs[index]['userImage'],
                    key: ValueKey(chatDocs[index].id)),
                itemCount: chatDocs.length,
              );
      },
    );
  }
}
