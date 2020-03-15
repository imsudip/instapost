import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/model/user.dart';

class AuthNotifier with ChangeNotifier {
  FirebaseUser _user;
  String _currentUserId;
  FirebaseUser get user => _user;
  String get currentUserid=>_currentUserId;
  User fullUser;
  void setCurrentUserId(String id){
    _currentUserId=id;
    notifyListeners();
  }
  void setUser(FirebaseUser user) async{
    _user = user;
    if(user!=null)
      fullUser= await getUser(user.uid,false);
    notifyListeners();
  }
}
