import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shop/service/database.dart';
import 'package:shop/widgets/app_constant.dart';
import 'package:shop/widgets/big_text.dart';


class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? wallet, uid;
  int? add;
  TextEditingController amountController = TextEditingController();
  Map<String, dynamic>? paymentIntent;

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
  
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: wallet == null? const CircularProgressIndicator(): Container(
        margin: const EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: const Center(
                  child: BigText(text: "Wallet"),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                children: [
                  Image.asset("assets/images/Wallet.png", height: 60, width: 60, fit: BoxFit.cover),
                  const SizedBox(width: 40),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Wallet"),
                      const SizedBox(height: 5.0,),
                      Text(
                        "\$${wallet!}",
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text("Add money",),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var amount in ['100', '500', '1000', '2000'])
                  GestureDetector(
                    onTap: () {
                      makePayment(amount);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE9E2E2)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text("\$$amount"),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 50),

            GestureDetector(
              onTap: () {
                openEdit();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFF008080),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text("Add Money"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        style: ThemeMode.dark,
        merchantDisplayName: 'Admin')).then((value) {});

      displayPaymentSheet(amount);
    } catch (e,s) {
      print('exception: $e$s');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      if (wallet == null) {
        print("Wallet is null");
        return;
      }

      await Stripe.instance.presentPaymentSheet().then((value) async {
        add = int.parse(wallet!) + int.parse(amount);
        await DatabaseMethods().updateUserWallet(uid!, add.toString());

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      BigText(text: "Payment Successful"),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        await getUserData();
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled"),
          ),
        );
      }
    } catch (e) {
      print('$e');
    }
  }

  // Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer  $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);

    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)*100);
    return calculatedAmount.toString();
  }

  Future openEdit() => showDialog(context: context, builder: (context) => AlertDialog(
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.cancel)),
              const SizedBox(width: 60.0,),
      
              const Center(
                child: Text(
                  "Add Money",
                  style: TextStyle(
                    color: Color(0xFF008080),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
      
          const Text("Amount"),
          const SizedBox(height: 10),
      
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black38, width: 2.0),
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: amountController,
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Enter Amount'),
            ),
          ),
          const SizedBox(height: 20),
      
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                makePayment(amountController.text);
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF008080),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text("Pay", style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ));
}