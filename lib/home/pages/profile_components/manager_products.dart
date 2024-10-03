import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/pages/profile_components/custom_product.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/small_text.dart';


class ManagerProducts extends StatefulWidget {
  const ManagerProducts({super.key});

  @override
  State<ManagerProducts> createState() => _ManagerProductState();
}

class _ManagerProductState extends State<ManagerProducts> {
  Stream? getItemFromUser;

  getUserData() async {
    getItemFromUser = await DatabaseMethods().getProductFromUser();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Widget allProducts() {
    return StreamBuilder(
        stream: getItemFromUser,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomProduct(
                    documentId: ds.id,
                    detail: ds["Detail"],
                    name: ds["Name"],
                    price: ds["Price"],
                    image: ds["Image"],
                    postedBy: ds["PostedBy"],  
                )));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Image.network(
                        ds["Image"],
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Center(
                          child: SmallText(text: ds["Name"])
                      ),
                      Center(
                          child: Text("\$${ds["Price"]}")
                      ),
                    ],
                  ),
                ),
              );
            },
          )
              : const Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: allProducts(),
      ),
    );
  }
}
