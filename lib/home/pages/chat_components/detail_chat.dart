import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:shop/service/database.dart';

class ChatDetail extends StatefulWidget{
  final String receiver, profileImage, chatRoomId;
  const ChatDetail({
    super.key, 
    required this.receiver, 
    required this.profileImage, 
    required this.chatRoomId
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  Stream? messageStream;
  late String? messageId;
  TextEditingController messageController = TextEditingController();


  addMessage(bool sendClicked) {
    if (messageController.text.isNotEmpty) {
      String currentMessage = messageController.text;
      messageController.clear();
      DateTime now = DateTime.now();
      String formattedDate= DateFormat('h:mm a').format(now);

      Map<String, dynamic> messageMap = {
        'Message': currentMessage,
        'Receiver': widget.receiver,
        'Ts': formattedDate,
        'Time': FieldValue.serverTimestamp(),
      };
      messageId = randomAlphaNumeric(10);
      DatabaseMethods().addMessage(messageMap, widget.chatRoomId, messageId!).then((value) {
        Map<String, dynamic> lastMessageMap = {
          'LastMessage': currentMessage,
          'LastMessageSendTs': formattedDate,
          'Time': FieldValue.serverTimestamp(),
          'LastMessageReceiver': widget.receiver,
        };
        DatabaseMethods().updateLastMessageSend(lastMessageMap, widget.chatRoomId);
        if (sendClicked) {
          messageId = "";
        }
      });
    }
  }


  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(widget.chatRoomId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAndSetMessages(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black,),
                ),
                const SizedBox(width: 2,),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.profileImage),
                  maxRadius: 20,
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.receiver ,style: const TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                      const SizedBox(height: 6,),
                      Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          chatMessage(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20, ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  const SizedBox(width: 15,),
                  GestureDetector(
                    onTap: () {
                      addMessage(true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.blue,))),
                  ),
                ],

              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
          ? ListView.builder(
            padding: const EdgeInsets.only(bottom: 90, top: 130),
            itemCount: snapshot.data.docs.length,
            reverse: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return messageTile(ds['Message'], widget.receiver == ds['Receiver']);
            }) 
          : const CircularProgressIndicator();
      }
    );
  }

  Widget messageTile(String message, bool messageSender) {
    return Container(
      alignment: messageSender ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: messageSender ? Colors.blue[400] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: messageSender ? const Radius.circular(24) : const Radius.circular(0),
                topRight: const Radius.circular(24),
                bottomLeft: const Radius.circular(24),
                bottomRight: messageSender ? const Radius.circular(0) : const Radius.circular(24),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: messageSender ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

}