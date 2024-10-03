import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/pages/home_components/category_product.dart';

import '../../../service/database.dart';
import '../../../widgets/big_text.dart';
import '../../../widgets/small_text.dart';
import '../../admin/detail_product.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  var _currentPageValue = 0.0;

  List<String> imageHeader = [
    "assets/images/banhmi.jpg",
    "assets/images/keo.jpg",
    "assets/images/suacogaihalan.jpg"
  ];
  List<String> imageCategories = [
    "assets/images/clock.jpg",
    "assets/images/thuoc.webp",
    "assets/images/cook.jpg",
    "assets/images/bag.png",
    "assets/images/books.webp",
    "assets/images/boyclothes.webp",
    "assets/images/girlclothes.jpg",
    "assets/images/laptop.jpg",
    "assets/images/motorbike.jpg",
    "assets/images/play.png",
  ];
  List<String> imageText = [
    "Đồng hồ",
    "Thuốc",
    "Đồ bếp",
    "Ba lô",
    "sách",
    "Đồ nam",
    "Đồ nữ",
    "Laptop",
    "Xe máy",
    "Đồ chơi",
  ];

  @override
  void initState() {
    onTheLoad();
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
    });
  }

  Stream? productItemStream;
  onTheLoad() async {
    productItemStream = await DatabaseMethods().getProductItem("Products");

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Widget allItemsVertically() {
    return StreamBuilder(
      stream: productItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
          ? ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
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
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ds["Image"],
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BigText(text:
                                ds["Name"],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "\$${ds["Price"]}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                ds["Detail"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
          : const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              itemBuilder: (context, position) {
                return _buildPageItem(position);
              }),
        ),
        DotsIndicator(
          dotsCount: 3,
          position: _currentPageValue,
          decorator: DotsDecorator(
            activeColor: Colors.cyan,
            size: const Size.square(9.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
        const SizedBox(height: 10),

        const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: BigText(text: "Category"),
            ),
          ],
        ),
        SizedBox(
          height: 190,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: imageCategories.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryProduct(category: imageText[index], )));
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white38,
                        image: DecorationImage(
                          image: AssetImage(imageCategories[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SmallText(text: imageText[index])
                ],
              );
            },
          ),
        ),
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: BigText(text: "Products"),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
            child: allItemsVertically()),
      ],
    );
  }

  Widget _buildPageItem(int index) {
    Matrix4 matrix = Matrix4.identity();
    double height = 120;

    if (index == _currentPageValue.floor()) {
      var currentScale = 1 - (_currentPageValue - index) * (1 - 0.8);
      var currentTrans = height * (1 - currentScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currentScale, 1)
        ..setTranslationRaw(0, currentTrans, 0);
    } else {
      var currentScale = 0.8;
      var currentTrans = height * (1 - currentScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currentScale, 1)
        ..setTranslationRaw(0, currentTrans, 0);
    }
    return Transform(
      transform: matrix,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(imageHeader[index]),
          ),
        ),
      ),
    );
  }
}
