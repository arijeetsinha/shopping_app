import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid = ''});

  //collection reference
  final CollectionReference brewCollection =
      FirebaseFirestore.instance.collection('brews');

  Future updateUserData(String title, String desc, double price) async {
    return await brewCollection.doc(uid).set({
      "title": title,
      "price": price,
      "desc": desc,
    });
  }

  //brew list from snapshot
  List<Product> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Product(
        title: doc.get('title') ?? '',
        desc: doc.get('desc') ?? '0',
        price: doc.get('price') ?? 0,
      );
    }).toList();
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        title: snapshot.get('title'),
        desc: snapshot.get('desc'),
        price: snapshot.get('price'),
        uid: uid);
  }

  //get brews stream
  Stream<List<Product>> get products {
    return brewCollection.snapshots().map(_brewListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return brewCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
