import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_wall/models/user.dart';

class DatabaseService {
  // Firestore documents to Model class in flutter
  // reference from https://petercoding.com/firebase/2022/02/16/how-to-model-your-firebase-data-class-in-flutter/

  Future<List<MyUser>> retrieveUsers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection("Users").get();
    return snapshot.docs
        .map((docSnapshot) => MyUser.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
