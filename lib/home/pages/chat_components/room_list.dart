import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/pages/chat_components/detail_chat.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/small_text.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, lastMessageReceiver, lastMessageSendTs, sender;

  const ChatRoomListTile({
    super.key, 
    required this.lastMessage, 
    required this.chatRoomId, 
    required this.lastMessageReceiver, 
    required this.lastMessageSendTs, 
    required this.sender, 
  });

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String name = "", profileImage ="";

  getThisUser() async {
    String targetName = widget.chatRoomId.replaceAll("_", "").replaceAll(widget.sender, "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUser(targetName);
    
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        name = querySnapshot.docs[0]['Name'];
        profileImage = querySnapshot.docs[0]['Profile_Image'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getThisUser();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute} ${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetail(
            receiver: name, 
            profileImage: profileImage,
            chatRoomId: widget.chatRoomId, 
        )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.network(
                profileImage,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SmallText(text: name),
                  const SizedBox(height: 5),
                    
                  Row(
                    children: [
                      Expanded(child: Text(widget.lastMessage, overflow: TextOverflow.ellipsis, maxLines: 1,)),
                      const SizedBox(width: 5),
                      const Text("- "),
                      Text(widget.lastMessageSendTs),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
