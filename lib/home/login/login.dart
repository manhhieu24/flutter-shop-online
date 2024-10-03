import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop/home/bottom_nav.dart';
import 'package:shop/home/login/forgot_password.dart';
import 'package:shop/home/login/sign_up.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/big_text.dart';
import 'package:shop/widgets/small_text.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";

  final _formKey = GlobalKey<FormState>();

  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password,);

      User? user = userCredential.user;
      
      if (user != null) {
        final userData = await FirebaseFirestore.instance
          .collection('Accounts')
          .doc(user.uid)
          .get();

        if (userData.exists) {
          String name = userData['Name'];
          String wallet = userData['Wallet'];
          print('User Name: $name');
          print('User Wallet: $wallet');
        }
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BottomNav()));
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = "No User Found for that Email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong Password Provided by User";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The Email Address is Badly Formatted";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This User has been Disabled";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too Many Requests. Try again later.";
      }


      if (mounted && errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: SmallText(text: errorMessage),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: SmallText(text: "An unexpected error occurred. Please try again."),
        ));
      }
    }
  }


  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          await saveUserToFirestore(firebaseUser, googleUser.photoUrl);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BottomNav()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: SmallText(text: "Google Sign-In failed. Please try again."),
        ));
      }
    }
  }

  Future<void> saveUserToFirestore(User firebaseUser, String? photoUrl) async {
    final userRef = FirebaseFirestore.instance.collection('Accounts').doc(firebaseUser.uid);
    final userSnapshot = await userRef.get();
    String firstLetter = firebaseUser.displayName!.substring(0,1).toUpperCase();

    if (!userSnapshot.exists) {
      Map<String, dynamic> newUserMap = {
        "Name": firebaseUser.displayName,
        "Email": firebaseUser.email,
        "Profile_Image": photoUrl ?? "",
        "Wallet": "0",
        "Uid": firebaseUser.uid,
        "SearchKey": firstLetter,
        "UpdatedName":firebaseUser.displayName?.toUpperCase(),
      };
      await userRef.set(newUserMap);
      await DatabaseMethods().addUser(newUserMap, firebaseUser.uid);
    } else {
      Map<String, dynamic> existingUserData = userSnapshot.data() as Map<String, dynamic>;
      print('User already exists: ${existingUserData['Name']}');
      Map<String, dynamic> updatedUserMap = {
        "Name": firebaseUser.displayName ?? existingUserData['Name'],
        "Email": firebaseUser.email ?? existingUserData['Email'],
        "Profile_Image": photoUrl ?? existingUserData['Profile_Image'],
        "Wallet": existingUserData['Wallet'],
        "Uid": firebaseUser.uid,
        "SearchKey": firstLetter,
        "UpdatedName":firebaseUser.displayName?.toUpperCase(),
      };
      await userRef.update(updatedUserMap);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 135, left: 30, right: 30),
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 450,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const BigText(text: "Login"),
                          TextFormField(
                            controller: userEmailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter Email";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.email_outlined)),
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: userPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter Password";
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.lock_outlined),
                            ),
                          ),
                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()));
                            },
                            child: Container(
                              alignment: Alignment.topRight,
                              child: const SmallText(
                                text: "Forgot Password?")
                            ),
                          ),
                          const SizedBox(height: 45),

                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  email = userEmailController.text;
                                  password = userPasswordController.text;
                                });
                                await userLogin();
                              }
                            },
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                width: 180,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                    child: BigText(text: "LOGIN")),
                              ),
                            ),
                          ),
                          const SizedBox(height: 45),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            label: const Text("Sign in with Google", style: TextStyle(color: Colors.green),),
                            onPressed: googleSignIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                            },
                            child: const SmallText(text: "Don't have an account? Sign up")
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
