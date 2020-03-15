import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/model/post.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:instapost/notifier/post_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

login(User user, AuthNotifier authNotifier,BuildContext context) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => BotToast.showText(text: "${error.toString()}"));

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      print("Log In: $firebaseUser");
      authNotifier.setUser(firebaseUser);
      
      BotToast.showText(text: "Login Successful");
      Navigator.of(context).pop();
    }
  }
}

signup(User user, AuthNotifier authNotifier,BuildContext context) async {
 
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => BotToast.showText(text: "${error.code.toString()}"));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.displayName;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);

      await firebaseUser.reload();

      print("Sign up: $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      authNotifier.setUser(currentUser);
      user.id=currentUser.uid;
      user.image="https://firebasestorage.googleapis.com/v0/b/instapost-post.appspot.com/o/placeholder%2Fplaceholder.png?alt=media&token=ca135aa5-da1e-48c2-af9a-abb1fb777d6a";
      createUserData(user, false,authNotifier, (){});
      BotToast.showText(text: "SignUp Successful");
      Navigator.of(context).pop();
      //authNotifier.setCurrentUserId(currentUser.uid);
    }
  }
}

signout(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((error) => print(error.code));

  authNotifier.setUser(null);
  authNotifier.fullUser=null;
}

initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null) {
    print(firebaseUser);
    authNotifier.setUser(firebaseUser);
   // User user= await getUser(firebaseUser.uid);
  }
}

 getPosts(PostNotifier postNotifier) async{
  print("getposts called");
 QuerySnapshot snapshot= await Firestore.instance
      .collection('Posts')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Post> _postList = [];

  snapshot.documents.forEach((document) {
    Post post = Post.fromMap(document.data);
    _postList.add(post);
  });

  postNotifier.postList = _postList;
  
}

uploadPostAndImage(Post post, bool isUpdating, File localFile,AuthNotifier authNotifier, VoidCallback postUploaded) async {
  if (localFile != null) {
    print("uploading image");

    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Posts/images/$uuid$fileExtension');

    await firebaseStorageRef.putFile(localFile).onComplete.catchError((onError) {
      print(onError);
      return false;
    });

    String url = await firebaseStorageRef.getDownloadURL();
    print("download url: $url");
    _uploadPost(post, isUpdating,authNotifier, postUploaded, imageUrl: url);
  } else {
    print('...skipping image upload');
    _uploadPost(post, isUpdating,authNotifier, postUploaded);
  }
}

_uploadPost(Post post, bool isUpdating,AuthNotifier authNotifier, VoidCallback postUploaded, {String imageUrl}) async {
  CollectionReference postRef = Firestore.instance.collection('Posts');

  if (imageUrl != null) {
    post.image = imageUrl;
  }

  if (isUpdating) {
    post.updatedAt = Timestamp.now();

    await postRef.document(post.id).updateData(post.toMap());
   print('updated Post with id: ${post.id}');
   BotToast.showNotification(
      title: (cancelFunc) => Text("Your post is Updated succesfully",style: TextStyle(fontWeight: FontWeight.bold),),
    );
    postUploaded();
   
  } else {
    post.createdAt = Timestamp.now();

    DocumentReference documentRef = await postRef.add(post.toMap());

    post.id = documentRef.documentID;
    post.userid=authNotifier.user.uid;
    print('uploaded Post successfully: ${post.toString()}');

    await documentRef.setData(post.toMap(), merge: true);
    await addUserPost(authNotifier.user.uid,post.id,authNotifier);
    //BotToast.showText(text: "Your post is uploaded succesfully");
    BotToast.showNotification(
      title: (cancelFunc) => Text("Your post is uploaded succesfully",style: TextStyle(fontWeight: FontWeight.bold),),
    );
    postUploaded();
  }
}

deletePost(Post post, VoidCallback postDeleted) async {
  if (post.image != null) {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(post.image);

    print(storageReference.path);

    await storageReference.delete();

    print('image deleted');
  }

  await Firestore.instance.collection('Posts').document(post.id).delete();
  postDeleted();
}
Post findPost(String id){
   return postcache.firstWhere(
    (element) {
      print("Post found..");
      if (element.id == id)
        return true;
      else
        return false;
    },
    orElse: () => null,
  );
}
getPost(String postId)async{
  Post post;
  CollectionReference postRef=Firestore.instance.collection("Posts");
  var snap= await postRef.document(postId).get();
  post=Post.fromMap(snap.data);
  return post;

}
List<Post> postcache=[];

