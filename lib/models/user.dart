import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String? id;
  final String username;
  final String bio;
  final String fcmToken;

  MyUser(
    // the id is not required beacuse it's nullable above
    this.id, {
    required this.username,
    required this.bio,
    required this.fcmToken,
  });

  // Firestore documents to Model class in flutter
  // reference from https://petercoding.com/firebase/2022/02/16/how-to-model-your-firebase-data-class-in-flutter/

  MyUser.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        username = doc.data()!["username"],
        bio = doc.data()!["bio"],
        fcmToken = doc.data()!["FcmToken"];
}
