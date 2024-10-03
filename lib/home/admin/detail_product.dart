import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/pages/chat_components/detail_chat.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/big_text.dart';
import 'package:shop/widgets/small_text.dart';

class Details extends StatefulWidget {
  final String image, name, detail, price, postedBy;
  const Details({
    super.key, 
    required this.detail,
    required this.image,
    required this.name,
    required this.price, 
    required this.postedBy, 
    });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int a = 1, total = 0;
  String? sender, chatRoomId, profileImage, uid;

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0,1).codeUnitAt(0)> b.substring(0,1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(user.uid)
        .get();
      QuerySnapshot querySnapshot = await DatabaseMethods().getUser(widget.postedBy);
      setState(() {
        sender = userDoc['Name'];
        if (querySnapshot.docs.isNotEmpty) {
          profileImage = querySnapshot.docs[0]['Profile_Image'];
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    total = int.parse(widget.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.black,
                )),
            Image.network(
              widget.image,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              fit: BoxFit.fill,
            ),
            const SizedBox(
              height: 15.0,
            ),
            BigText(text: widget.name,),
            const SizedBox(height: 10.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Owner: ${widget.postedBy}"),
                ElevatedButton(
                  onPressed: () async {
                    var chatRoomId = getChatRoomIdByUsername(sender!, widget.postedBy);
                    Map<String, dynamic> chatRoomMap = {
                      'Users':[sender, widget.postedBy],
                    };
                    await DatabaseMethods().createChatRoom(chatRoomMap, chatRoomId);
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetail(
                        receiver: widget.postedBy, 
                        profileImage: profileImage!,
                        chatRoomId: chatRoomId, 
                      )));
                    }
                  },
                  child: const Text("Chat"))
              ],
            ),
            const SizedBox(height: 20.0,),

            SmallText(text: widget.detail),
            const SizedBox(height: 30.0,),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (a > 1) {
                      --a;
                      total = total - int.parse(widget.price);
                    }
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20.0,),

                Text(a.toString(),),
                const SizedBox(width: 20.0,),
                GestureDetector(
                  onTap: () {
                    ++a;
                    total = total + int.parse(widget.price);
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
   
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SmallText(text: "Total Price:",),
                      Text("\$$total",)
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      Map<String, dynamic> addProductToCart = {
                        "Name": widget.name,
                        "Quantity": a.toString(),
                        "Total": total.toString(),
                        "Image": widget.image
                      };

                      try {
                        await DatabaseMethods().addProductToCart(addProductToCart, uid!);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: SmallText(text: "Product Added to Cart"),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: SmallText(text: "Failed to add product: $e"),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: BigText(text: "Add to cart"),
                      ),
                    ),


                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}