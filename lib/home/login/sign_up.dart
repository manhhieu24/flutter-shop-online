import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/bottom_nav.dart';
import 'package:shop/home/login/login.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/big_text.dart';
import 'package:shop/widgets/small_text.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email="", password="", name="", confirmPassword="";

  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
 
  registration() async {
    if (password == confirmPassword && password.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;

        if (user != null) {
          String uid = user.uid;
          String firstLetter = nameController.text.substring(0,1).toUpperCase();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: SmallText(text: "Registered Successfully"),
            ));
          }
          Map<String, dynamic> userMap = {
            "Name": nameController.text,
            "Email": mailController.text,
            "Profile_Image": "https://firebasestorage.googleapis.com/v0/b/shop-online-bd413.appspot.com/o/Profile_Image%2Fprofile.jpg?alt=media&token=c3a7685e-f047-4aa9-8c33-90112e12ec0a",
            "Wallet": "0",
            "Uid": uid,
            "SearchKey": firstLetter,
            "UpdatedName":nameController.text.toUpperCase(),
          };    
          await DatabaseMethods().addUser(userMap, uid);
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNav()),
          );
        }
      } on FirebaseException catch (e) {
        String errorMessage = '';
        if (e.code == 'weak-password') {
          errorMessage = "Password Provided is too Weak";
        } else if (e.code == "email-already-in-use") {
          errorMessage = "Account Already exists";
        }
        if (mounted && errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: SmallText(text: errorMessage),
          ));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: SmallText(text: "Passwords do not match"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60.0, left: 20, right: 20),
            child: Column(
              children: [
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    width: MediaQuery.of(context).size.width,
                    height: 530,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const BigText(text: 
                            "Sign up",
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Full Name';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: 'Full Name',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.person_outlined)),
                          ),
                          const SizedBox(height: 30),
                          
                          TextFormField(
                            controller: mailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter E-mail';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.email_outlined)
                            ),
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.lock_outline)
                            ),
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Re-Enter Password';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.lock_outlined)
                            ),
                          ),
                          const SizedBox(height: 45),
      
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  email = mailController.text;
                                  name = nameController.text;
                                  password = passwordController.text;
                                  confirmPassword = confirmPasswordController.text;
                                });
                              }
                              registration();
                            },
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Center(
                                    child: BigText(text: "SIGN UP")),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24,),
      
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const Login()));
                            },
                            child: const SmallText(text: 
                              "Already have an account? Login",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      
              ],
            ),
          )
        ],
      ),
    );
  }
}