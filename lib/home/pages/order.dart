import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/big_text.dart';
import 'package:shop/widgets/small_text.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

  class _OrderState extends State<Order> {
    String? uid, wallet;
    int total = 0, amount2 = 0;
    Stream? productStream;

  void startTimer(){
    Timer(const Duration(seconds: 2), () { 
      amount2 = total;
      if (mounted) {
        setState(() {});
      }
    });
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
          uid = userDoc['Uid'];
          wallet = userDoc['Wallet'];
        });
      }
    }
  }

  onTheLoad() async {
    await getUserData();
    if (uid != null) {
      productStream = await DatabaseMethods().getProductCart(uid!);
      if (mounted) {
        setState(() {});
      }
    } else {
      print("Failed to retrieve User UID");
    }
  }

  @override
  void initState() {
    onTheLoad();
    startTimer();
    super.initState();
  }

  Widget productCart() {
    return StreamBuilder(
        stream: productStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  total= total+ int.parse(ds["Total"]);
                  return Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              height: 90,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(15)),
                              child: Center(child: Text(ds["Quantity"])),
                            ),
                            const SizedBox(width: 20),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  ds["Image"],
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                )),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  SmallText(text: ds["Name"],),
                                  Text("\$${ds["Total"]}",)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
              : const CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Center(
                  child: BigText(text: "Your Cart")
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height/2,
              child: productCart()
            ),
            const Divider(),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SmallText(text: "Total Price:",),
                const SizedBox(width: 10),
                Text("\$$total")
              ],
            ),
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: () async {
                int newWalletAmount = int.parse(wallet!)-amount2;
                await DatabaseMethods().updateUserWallet(uid!, newWalletAmount.toString());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: const Center(
                  child: BigText(text: "CheckOut")
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}