import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instapost/model/post.dart';
import 'package:uuid/uuid.dart';
import 'package:instapost/widgets/post_widget.dart';

User findUser(String id) {
  return userList.firstWhere(
    (element) {
      print("user found..");
      if (element.id == id)
        return true;
      else
        return false;
    },
    orElse: () => null,
  );
}

Future<User> getUser(String id, bool canSearch) async {
  User user;
  if (canSearch) user = findUser(id);
  if (user != null)
    return user;
  else {
    print("getting user from server");
    CollectionReference userRef = Firestore.instance.collection('Users');
    var snap = await userRef.document(id).get();
    user = User.fromMap(snap.data);
    userList.add(user);

    return user;
  }
}

createUserData(User user, bool isupdating, AuthNotifier authNotifier,
    Function postUploaded) async {
  //  user.createdAt = Timestamp.now();
  CollectionReference userRef = Firestore.instance.collection('Users');
  if (isupdating) {
    await userRef.document(user.id).updateData(user.toMap());

    postUploaded(Post);
    print('updated Post with id: ${user.id}');
  } else {
    // DocumentReference documentRef = await userRef.add(user.toMap());

    user.id = authNotifier.user.uid;
    await userRef.document(user.id).setData(user.toMap());

    print('uploaded Post successfully: ${user.toString()}');

    //await documentRef.setData(user.toMap(), merge: true);

    postUploaded(user);
  }
}

uploadUserImage(User user, File localFile, VoidCallback completed) async {
  print("uploading profile image");

  var fileExtension = path.extension(localFile.path);
  print(fileExtension);

  var uuid = Uuid().v4();

  final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('Posts/images/$uuid$fileExtension');

  await firebaseStorageRef.putFile(localFile).onComplete.catchError((onError) {
    print(onError);
    BotToast.showText(text: onError.code.toString());
    return false;
  });

  String url = await firebaseStorageRef.getDownloadURL();
  CollectionReference userRef = Firestore.instance.collection('Users');
  if (user.image != null) {
    StorageReference storageReference1 =
        await FirebaseStorage.instance.getReferenceFromUrl(user.image);

    print(storageReference1.path);

    await storageReference1.delete();

    print('image deleted');
  }
  user.image = url;
  await userRef.document(user.id).updateData(user.toMap());
  completed();
}

addUserPost(String userId, String postId, AuthNotifier authNotifier) async {
  User user;
  CollectionReference userRef = Firestore.instance.collection('Users');
  var snap = await userRef.document(userId).get();
  user = User.fromMap(snap.data);
  List<String> posts = [];
  if (user.posts != null) {
    var dlist = user.posts;
    var s = dlist.cast<String>().toList();
    posts.addAll(s);
  }
  posts.add(postId);
  user.posts = posts;
  authNotifier.fullUser = user;
  await userRef.document(user.id).updateData(user.toMap());
}
 
changeUserName(AuthNotifier authNotifier,User user,String name,VoidCallback v)async{
  FirebaseUser firebaseUser=authNotifier.user;
  UserUpdateInfo updateInfo=UserUpdateInfo();
  updateInfo.displayName=name;
  firebaseUser.updateProfile(updateInfo);
  //authNotifier.user.reload();
  authNotifier.setUser(firebaseUser);
  CollectionReference userRef = Firestore.instance.collection('Users');
  var snap = await userRef.document(user.id).get();
  User temp=User.fromMap(snap.data);
  temp.displayName=name;
  await userRef.document(user.id).updateData(temp.toMap());
  //authNotifier.fullUser=temp;
 int i= userList.indexWhere((element) => element.id==temp.id);
 userList[i]=temp;
  v();
  
}
