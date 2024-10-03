import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shop/service/database.dart';
import '../../widgets/big_text.dart';
import '../admin/detail_product.dart';
import 'home_components/body.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  bool isLoading = false;
  List queryResultSet = [];
  List tempSearchStore = [];
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      initiateSearch(value.toUpperCase());
    });
  }

  initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }

    setState(() {
      search = true;
      isLoading = true;
    });

    String capitalizedValue = value[0].toUpperCase() + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().searchProduct(capitalizedValue).then((QuerySnapshot docs) {
        setState(() {
          queryResultSet = docs.docs.map((doc) => doc.data()).toList();
          isLoading = false; 
        });
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['UpdatedName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
      setState(() {
        isLoading = false; 
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Center(
              child: BigText(text: "Shop Online")
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search Product...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: search
                    ? GestureDetector(
                      onTap: () {
                        search = false;
                        tempSearchStore = [];
                        queryResultSet = [];
                        searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    )
                    : const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(8),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    )
                  ),
                ),
              ),
            ),
            isLoading
                ? const CircularProgressIndicator() 
                : search
                ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList(),
            )
                : const Body(),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              detail: data["Detail"],
              name: data["Name"],
              price: data["Price"],
              image: data["Image"],
              postedBy: data["PostedBy"], 
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(data["Image"], height: 70, width: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 20),
            Text(data["Name"], style: const TextStyle(overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
