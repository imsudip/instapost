import 'dart:io';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/screens/feed.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/model/post.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:instapost/notifier/post_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostForm extends StatefulWidget {
  final bool isUpdating;
  final FirebaseUser user;
  PostForm({@required this.isUpdating, this.user});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  User u;

  List _subingredients = [];
  Post _currentPost;
  String _imageUrl;
  File _imageFile;
  //String currentUserId;
  TextEditingController subingredientController = new TextEditingController();

  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  bool isAdded = false;

  @override
  void initState() {
    super.initState();
    PostNotifier postNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    //currentUserId=authNotifier.currentUserid;
    // print(authNotifier.currentUserid);
    if (postNotifier.currentPost != null) {
      _currentPost = postNotifier.currentPost;
    } else {
      _currentPost = Post();
    }

    _subingredients.addAll(_currentPost.subIngredients);
    _imageUrl = _currentPost.image;
    u=findUser(widget.user.uid);
  }

  _showImageWidget() {
    if (_imageFile == null && _imageUrl == null)
      return Container();
    else
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width * 0.8,
          color: CupertinoColors.extraLightBackgroundGray,
          child: Stack(
            children: <Widget>[
              Center(
                child: Image.file(
                  _imageFile,
                  fit: BoxFit.cover,
                  //height: 500,
                ),
              ),
              Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _imageFile = null;
                          isAdded = false;
                        });
                      },
                      child: Icon(
                        CupertinoIcons.clear_circled_solid,
                        size: 32,
                        color: CupertinoColors.destructiveRed,
                      )))
            ],
          ),
        ),
      );
  }

  _getLocalImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 1080,maxHeight: 1980);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        //maxWidth: 1080,
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            backgroundColor: CupertinoColors.white,
            activeControlsWidgetColor: CupertinoColors.activeBlue ,
            dimmedLayerColor: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
            activeWidgetColor: CupertinoColors.activeBlue,
            cropFrameColor: CupertinoColors.lightBackgroundGray,
            toolbarTitle: 'Crop Image',
            toolbarColor: CupertinoColors.white,
            toolbarWidgetColor:CupertinoColors.activeBlue,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imageFile != null&&croppedFile!=null) {
      setState(() {
        //print(croppedFile.lengthSync());
        _imageFile = croppedFile;
        isAdded = true;
      });
    }
  }

  _onPostUploaded() {
        PostNotifier postNotifier = Provider.of<PostNotifier>(context,listen: false);

        getPosts(postNotifier);
    
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      isAdded=false;
    });
    // PostNotifier postNotifier =
    //     Provider.of<PostNotifier>(context, listen: false);
    // postNotifier.addPost(post);
    // print("post saved called");
    _imageFile = null;
    _imageUrl=null;
    _currentPost.image=null;
      _currentPost.description=null;
    //Navigator.pop(context);
  }

  _savePost() {
    print('savePost Called');

    _currentPost.subIngredients = _subingredients;
    // _currentPost.userid=currentUserId;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    uploadPostAndImage(_currentPost, widget.isUpdating, _imageFile,
        authNotifier, _onPostUploaded);

    print("title: ${_currentPost.title}");
    print("description: ${_currentPost.description}");
    print("subingredients: ${_currentPost.subIngredients.toString()}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
           heroTag: "Addpost",
          largeTitle: Text("Add Post"),
          trailing: CupertinoButton(
              padding: EdgeInsets.only(bottom: 3),
              child: Text(
                "post",
                style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (_currentPost.title == null || _currentPost.title == "")
                  BotToast.showText(text: "Title cannot be empty");
                else {
                  BotToast.showText(text: "Your post is being uploaded");
                  tabController.index=0;
                  _savePost();
                }
              }),
        ),
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: EdgeInsets.all(10),
        //     child: Row(
        //       children: <Widget>[
        //         CircleAvatar(
        //           //minRadius: 50,
        //           // maxRadius: 80,
        //           radius: MediaQuery.of(context).size.height * 0.03,
        //           backgroundColor: Colors.orangeAccent,
        //           child: Text(
        //             "${widget.user.displayName.substring(0, 2).toUpperCase()}",
        //             style: TextStyle(
        //                 color: Colors.white70,
        //                 fontSize: 18,
        //                 fontWeight: FontWeight.w500),
        //           ),
        //         ),
        //         SizedBox(
        //           width: 5,
        //         ),
        //         Text(
        //           "${widget.user.displayName}",
        //           style: TextStyle(
        //               color: Colors.black,
        //               fontSize: 18,
        //               fontWeight: FontWeight.w700),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(7),
            child: Column(
              children: <Widget>[
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: "Add Title",
                  clearButtonMode: OverlayVisibilityMode.editing,
                  maxLines: 1,
                  style: TextStyle(fontSize: 22),
                  onSubmitted: (value) {
                    _currentPost.title = value;
                    print(value);
                  },
                  onChanged: (value) {
                    _currentPost.title = value;
                    print(value);
                  },
                ),
                SizedBox(
                  height: 7,
                ),
                CupertinoTextField(
                  controller: _descriptionController,
                  placeholder: "Add Description",
                  clearButtonMode: OverlayVisibilityMode.editing,

                  maxLines: 4,
                  //style: TextStyle(fontSize: 22),
                  onSubmitted: (value) {
                    _currentPost.description = value;
                    print(value);
                  },
                  onChanged: (value) {
                    _currentPost.description = value;
                    print(value);
                  },
                )
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoButton(
                child: Text(
                  isAdded ? "Change Image" : "Add Image",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _getLocalImage(),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: _showImageWidget(),
          ),
        ),
      ],
    );
  }
}
