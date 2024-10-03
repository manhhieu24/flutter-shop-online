import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/widgets/big_text.dart';
import 'package:shop/widgets/small_text.dart';
import '../../../service/database.dart';

class CustomProduct extends StatefulWidget {
  final String image, name, detail, price, postedBy, documentId;
  const CustomProduct({
    super.key, 
    required this.detail,
    required this.image,
    required this.name,
    required this.price, 
    required this.postedBy, 
    required this.documentId,  
    });

  @override
  State<CustomProduct> createState() => _CustomProductState();
}

class _CustomProductState extends State<CustomProduct> {
  int a = 1, total = 0;
  String? uid;


  @override
  void initState() {
    super.initState();
    getCurrentUser();
    total = int.parse(widget.price);
  }

  getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      setState(() {});  
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              children: [
                const Text("Owner: "),
                Text(widget.postedBy),
              ],
            ),
            const SizedBox(height: 20.0,),

            SmallText(text: widget.detail),
   
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
                      try {
                        await DatabaseMethods().deleteProductFromAll(widget.documentId, widget.name); 
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Delete product successfully"),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Error while delete: $e")
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          BigText(text: "Delete Item"),
                        ],
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