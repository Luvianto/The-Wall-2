import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_wall/components/drawer.dart';
import 'package:the_wall/components/text_field.dart';
import 'package:the_wall/components/wall_post.dart';
import 'package:the_wall/helper/helper_methods.dart';
import 'package:the_wall/models/user.dart';
import 'package:the_wall/pages/profile_page.dart';
import 'package:the_wall/services/database_service.dart';
import 'package:the_wall/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text Controller
  final textController = TextEditingController();

  DatabaseService service = DatabaseService();
  Future<List<MyUser>>? userList;
  List<MyUser>? retrievedUserList;

  // all users
  // CollectionReference<Map<String, dynamic>>
  // final usersCollection = FirebaseFirestore.instance.collection('Users');

  // notification receiver
  final NotificationService _notiService = NotificationService();

  Future<void> _initRetrieval() async {
    userList = service.retrieveUsers();
    retrievedUserList = await userList;
    print('retrievedUserList: $retrievedUserList');
  }

  @override
  void initState() {
    super.initState();
    _notiService.configurePushNotification(context);
    _notiService.eventListenerCallBack(context);
    _initRetrieval();
  }

  // sign user out
  void signOut() async {
    if (GoogleSignIn().currentUser != null) {
      await GoogleSignIn().signOut();
    }

    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print('failed to disconnect on signout');
    }
    FirebaseAuth.instance.signOut();
  }

  //post message
  void postMessage() {
    //only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    // clear the input text after insert
    setState(() {
      textController.clear();
    });
  }

  //navigate to profile page
  void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to profile page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'The Wall',
          textAlign: TextAlign.center,
        ),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      body: FutureBuilder<List<MyUser>>(
        future: service.retrieveUsers(),
        builder: (context, userListSnapshot) {
          if (userListSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (userListSnapshot.hasError) {
            return Center(
              child:
                  Text('Error retrieving user list: ${userListSnapshot.error}'),
            );
          } else {
            final List<MyUser>? retrievedUserList = userListSnapshot.data;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy(
                    "TimeStamp",
                    descending: false,
                  )
                  .snapshots(),
              builder: (context, postSnapshot) {
                if (postSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                } else if (postSnapshot.hasError) {
                  return Center(
                    child: Text(
                        'Error retrieving user posts: ${postSnapshot.error}'),
                  );
                } else {
                  final posts = postSnapshot.data!.docs;
                  return _buildPostList(posts, retrievedUserList);
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildPostList(
      List<DocumentSnapshot> posts, List<MyUser>? retrievedUserList) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final user = retrievedUserList!
                    .where((element) => element.id!.contains(post['UserEmail']))
                    .first;
                return WallPost(
                  message: post['Message'],
                  user: post['UserEmail'],
                  postId: post.id,
                  likes: List<String>.from(post['Likes'] ?? []),
                  time: formatDate(post['TimeStamp']),
                  token: user.fcmToken,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: 'Write something!',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_circle_up),
                  onPressed: postMessage,
                )
              ],
            ),
          ),
          Text(
            "Logged in as:  ${currentUser.email!}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
