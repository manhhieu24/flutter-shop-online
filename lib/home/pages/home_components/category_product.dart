import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/service/database.dart';
import 'package:shop/widgets/small_text.dart';
import '../../admin/detail_product.dart';

class CategoryProduct extends StatefulWidget {
  final String category;
  const CategoryProduct({super.key, required this.category});

  @override
  State<CategoryProduct> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  Stream? categoryStream;

  onTheLoad() async {
    categoryStream = await DatabaseMethods().getProductItem(widget.category);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    onTheLoad();
    super.initState();
  }

  Widget allProducts() {
    return StreamBuilder(
        stream: categoryStream,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Details(
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
