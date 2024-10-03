import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/pages/chat_components/detail_chat.dart';
import 'package:shop/home/pages/chat_components/room_list.dart';
import '../../service/database.dart';



class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool search = false;
  bool isLoading = false;
  List queryResultSet = [];
  List tempSearchStore = [];
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  Stream? chatRoomStream;
  String? sender, chatRoomId, uid;

  setRoomList() async {
    chatRoomStream = await DatabaseMethods().getChatRooms(sender!);
    setState(() {});
  }

  getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(user.uid)
        .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          sender = userDoc['Name'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((_) {
    setRoomList();
  });
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0,1).codeUnitAt(0)> b.substring(0,1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      initiateSearch(value.toUpperCase());
    });
  }

  initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }
    setState(() {
      search = true;
      isLoading = true;
    });

    String capitalizedValue = value[0].toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().searchUser(capitalizedValue).then((QuerySnapshot docs) {
        setState(() {
          queryResultSet = docs.docs.map((doc) => doc.data()).toList();
          isLoading = false; 
        });
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['UpdatedName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
      setState(() {
        isLoading = false; 
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16,right: 16,top: 10),
                child: Text("Conversations",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: search
                    ? GestureDetector(
                      onTap: () {
                        search = false;
                        tempSearchStore = [];
                        queryResultSet = [];
                        searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    )
                    : const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(8),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    )
                  ),
                ),
              ),
            ),
            isLoading
              ? const CircularProgressIndicator() 
              : search
              ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultUser(element);
              }).toList(),
            ) : chatRoomList(),
          ],
        ),
      ),
    );
  }
    Widget buildResultUser(data) {
     return GestureDetector(
      onTap: () async {
        var chatRoomId = getChatRoomIdByUsername(sender!, data['Name']);
        Map<String, dynamic> chatRoomMap = {
          'Users':[sender, data['Name']],
        };
        await DatabaseMethods().createChatRoom(chatRoomMap, chatRoomId);
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetail(
            receiver: data['Name'], 
            profileImage: data['Profile_Image'],
            chatRoomId: chatRoomId, 
          )));
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        height: 60,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(data['Profile_Image'], height: 50, width: 50, fit: BoxFit.cover)
            ),
            const SizedBox(width: 20),
            Text(data['Name'], style: const TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) { 
        return snapshot.hasData 
          ? ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return ChatRoomListTile(
                chatRoomId: ds.id,
                sender: sender!,
                lastMessage: ds['LastMessage'],
                lastMessageReceiver: ds['LastMessageReceiver'],
                lastMessageSendTs: ds['LastMessageSendTs'],
              );
            }
          ) 
          : const CircularProgressIndicator();
      }
    );
  }

}