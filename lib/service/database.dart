import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  Future<void> addUser(Map<String, dynamic> userMap, String uid) async {
    try {
      await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(uid)
        .set(userMap);
    } catch (e) {
      print('Error adding user detail: $e');
    }
  }

  Future<void> updateUserWallet(String uid, String amount) async {
    try {
      await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(uid)
        .update({"Wallet": amount});
    } catch (e) {
      print('Error updating wallet: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> productMap, String name) async {
    String productId = FirebaseFirestore.instance.collection(name).doc().id;
    productMap['ProductId'] = productId;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference productsRef = FirebaseFirestore.instance.collection(name).doc(productId);
    batch.set(productsRef, productMap);
    DocumentReference allProductsRef = FirebaseFirestore.instance.collection('Products').doc(productId);
    batch.set(allProductsRef, productMap);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference userProductRef = FirebaseFirestore.instance
        .collection('Accounts')
        .doc(currentUser.uid)
        .collection('Products')
        .doc(productId);
      batch.set(userProductRef, productMap);
    }
    try {
      await batch.commit();
      print('Product added successfully with productId: $productId');
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<Stream<QuerySnapshot>> getProductItem(String name) async {
    try {
      return FirebaseFirestore.instance
        .collection(name)
        .snapshots();
    } catch (e) {
      print('Error getting product items: $e');
      rethrow;
    }
  }

  Future<void> addProductToCart(Map<String, dynamic> userMap, String uid) async {
    try {
      await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(uid)
        .collection('Cart')
        .add(userMap);
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  Future<Stream<QuerySnapshot>> getProductCart(String uid) async {
    try {
      return FirebaseFirestore.instance
        .collection('Accounts')
        .doc(uid)
        .collection('Cart')
        .snapshots();
    } catch (e) {
      print('Error getting product cart: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> searchProduct(String updatedName) async {
    return await FirebaseFirestore.instance
      .collection('Products')
      .where('SearchKey', isEqualTo: updatedName.substring(0,1).toUpperCase())
      .get();
  }

  Future<QuerySnapshot> searchUser(String updatedName) async {
    return await FirebaseFirestore.instance
      .collection('Accounts')
      .where('SearchKey', isEqualTo: updatedName.substring(0,1).toUpperCase())
      .get();
  }

  Future<Stream<QuerySnapshot>> getProductFromUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userUid = currentUser.uid;
        return FirebaseFirestore.instance
          .collection('Accounts')
          .doc(userUid)
          .collection('Products')
          .snapshots();
    } else {
      throw Exception("User not logging");
    }
  }

  Future<void> deleteProductFromAll(String productId, name) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference productsRef = FirebaseFirestore.instance.collection(name).doc(productId);
    batch.delete(productsRef);
    DocumentReference allProductsRef = FirebaseFirestore.instance.collection('Products').doc(productId);
    batch.delete(allProductsRef);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference userProductRef = FirebaseFirestore.instance
        .collection('Accounts')
        .doc(currentUser.uid)
        .collection('Products')
        .doc(productId);
      batch.delete(userProductRef);

      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('Accounts')
          .doc(currentUser.uid)
          .collection('Cart')
          .where('ProductId', isEqualTo: productId)
          .get();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
    }
    try {
      await batch.commit();
      print('Product deleted successfully with productId: $productId');
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> createChatRoom(Map<String, dynamic> chatRoomMap, String chatRoomId) async {
    final snapshot = await FirebaseFirestore.instance
      .collection('Chat Room')
      .doc(chatRoomId)
      .get();
    if (snapshot.exists) {
      return;
    } else {
      return FirebaseFirestore.instance
        .collection('Chat Room')
        .doc(chatRoomId)
        .set(chatRoomMap);
    }
  }

  Future<void> addMessage(Map<String, dynamic> messageMap, String chatRoomId, String messageId) async {
    return FirebaseFirestore.instance
      .collection('Chat Room')
      .doc(chatRoomId)
      .collection('Chats')
      .doc(messageId)
      .set(messageMap);
  }

  Future<void> updateLastMessageSend(Map<String, dynamic> lastMessageMap, String chatRoomId) async {
    return FirebaseFirestore.instance
      .collection('Chat Room')
      .doc(chatRoomId)
      .update(lastMessageMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
      .collection('Chat Room')
      .doc(chatRoomId)
      .collection('Chats')
      .orderBy('Time', descending: true)
      .snapshots();
  }

  Future<QuerySnapshot> getUser(String name) async {
    return await FirebaseFirestore.instance
      .collection('Accounts')
      .where('Name', isEqualTo: name)
      .where('Profile_Image')
      .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms(String sender) async {
    return FirebaseFirestore.instance
      .collection('Chat Room')
      .orderBy('Time', descending: true)
      .where('Users', arrayContains: sender)
      .snapshots();
  }
}
