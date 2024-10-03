import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shop/home/admin/add_products.dart';
import 'package:shop/home/login/login.dart';
import 'package:shop/home/pages/profile_components/manager_products.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profileImage, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    if (mounted) { 
      setState(() {
        uploadItem();
      });
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child("Profile_Image")
        .child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
          .collection('Accounts')
          .doc(user.uid)
          .update({"Profile_Image": downloadUrl});
      }
      if (mounted) {
        setState(() {});
      }
    }
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
          if (userData.containsKey('Profile_Image') && userDoc['Profile_Image'] != null) {
            profileImage = userDoc['Profile_Image'];
          }
          name = userDoc['Name'];
          email = userDoc['Email'];
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
      body: name==null? const CircularProgressIndicator(): Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
                height: MediaQuery.of(context).size.height / 4.3,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                      MediaQuery.of(context).size.width, 105
                    )
                  )
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 6.5),
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: selectedImage==null? GestureDetector(
                        onTap: (){
                          getImage();
                        },
                        child: Image.network(profileImage!, height: 120,width: 120, fit: BoxFit.cover),
                        )      
                        : Image.file(selectedImage!,  height: 120, width: 120, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name!),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.black,),
                    const SizedBox(width: 20.0,),
                    Text(email!),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),   

          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagerProducts()));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 2.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 20),      
                      Text("Product Management"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddProduct()));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 2.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Row(
                    children: [
                      Icon(Icons.description, color: Colors.black,),
                      SizedBox(width: 20),
                      Text("Create Product"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Login()),(route) => false);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 2.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 20),      
                      Text("Logout"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}