class User {
  String id;
  String displayName;
  String email;
  String password;
  String image;
  List posts;
  

  User();
  User.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    displayName = data['displayName'];
    email = data['email'];
    image = data['image'];
    posts = data['posts'];
  
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'image': image,
      'posts': posts,
    };
  }
}
