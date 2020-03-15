import 'dart:collection';

import 'package:instapost/model/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:instapost/model/user.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class PostNotifier with ChangeNotifier {
  List<Post> _postList = [];
  Post _currentPost;
  User _currentuser;
  List<Post> get postList => _postList;

  Post get currentPost => _currentPost;

  set postList(List<Post> postList) {
    _postList = postList;
    notifyListeners();
  }

  set currentUser(User user) {
    _currentuser = user;
    notifyListeners();
  }
  set currentPost(Post post) {
    _currentPost = post;
    notifyListeners();
  }

  addPost(Post post) {
    _postList.insert(0, post);
    notifyListeners();
  }

  deletePost(Post post) {
    _postList.removeWhere((_post) => _post.id == post.id);
    notifyListeners();
  }
}
