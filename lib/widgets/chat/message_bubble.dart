import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  //final String userId;
  final String username;
  final String userImage;
  final Key key;
  String capitalizeWords(String s) {
    String finalWord = "";
    var x = s.split(" ");
    for (var el in x) {
      finalWord += el[0].toUpperCase() + el.substring(1).toLowerCase();
      finalWord += " ";
    }
    return finalWord.trim();
  }

  MessageBubble(this.message, this.isMe, this.username, this.userImage,
      {required this.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.40,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.lightBlue : Colors.blue.shade800,
                borderRadius: isMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0))
                    : const BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0)),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // FutureBuilder<DocumentSnapshot>(
                  //     future: FirebaseFirestore.instance
                  //         .collection('users')
                  //         .doc(userId)
                  //         .get(),
                  //     builder: (ctx, snapshot) {
                  //       if (snapshot.connectionState == ConnectionState.waiting) {
                  //         return Text('Loading...');
                  //       }
                  //
                  //       return Text(
                  //         snapshot.data!['username'],
                  //         style: TextStyle(fontWeight: FontWeight.bold),
                  //       );
                  //     }),
                  Text(
                    capitalizeWords(username),
                    style: GoogleFonts.ubuntu(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).textScaleFactor * 12,
                      ),
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).textScaleFactor * 14,
                      ),
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
            top: 0,
            left: isMe ? null : 135,
            right: isMe ? 135 : null,
            child: CachedNetworkImage(
              placeholder: (ctx, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              imageUrl: userImage,
              imageBuilder: (ctx, provider) => CircleAvatar(
                backgroundImage: provider,
              ),
            )),
      ],
    );
  }
}
