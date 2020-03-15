import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String title;
  String description;
  String image;
  String userid;
  List subIngredients = [];
  Timestamp createdAt;
  Timestamp updatedAt;

  Post();

  Post.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    description = data['description'];
    image = data['image'];
    userid = data['userid'];
    //subIngredients = data['subIngredients'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'userid': userid,
      //'subIngredients': subIngredients,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
