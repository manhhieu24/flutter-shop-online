import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/login/sign_up.dart';
import 'package:shop/widgets/big_text.dart';
import 'package:shop/widgets/small_text.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mailController = TextEditingController();

  String email = "";

  final _formKey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: BigText(text: "Password Reset Email has been sent!"),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: BigText(text: "No user found for that email."),
          ));
        }
      } else {
        print("Firebase Auth Error: ${e.message}"); 
      }
    } catch (e) {
      print("Unknown Error: $e"); 
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 70.0),
          Container(
            alignment: Alignment.topCenter,
            child: const BigText(text: "Password Recovery"),
          ),
          const SizedBox(height: 10.0,),
          const BigText(text: "Enter your mail"),

          Expanded(
            child: Form(
              key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextFormField(
                          controller: mailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Email';
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please Enter a Valid Email';
                            } return null;
                          },
                          decoration: const InputDecoration(
                              hintText: "Email",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 30.0,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      GestureDetector(
                        onTap: (){
                          if(_formKey.currentState!.validate()) {
                            setState(() {
                              email = mailController.text;
                            });
                            print("Email: $email");
                            resetPassword();
                          }
                        },
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(left: 45, right: 45),
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(
                            child: BigText(text: "Send Email"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                  
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUp()));
                          },
                          child: const SmallText(text: "Don't have an account? Create"),
                        ),
                      )
                    ],
            ),
          ))),
        ],
      ),
    );
  }
}