import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/colors.dart';
import 'package:instapost/model/post.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:instapost/notifier/post_notifier.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';

class EditPost extends StatefulWidget {
  final Post post;
  EditPost({Key key, this.post}) : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  Post _currentPost;
  User user;

  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  bool isAdded = false;

  File _imageFile;

  onPostUploaded(){
    Navigator.of(context).pop();
  }
  _savePost(){
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
   uploadPostAndImage(_currentPost, true, _imageFile, authNotifier, onPostUploaded);
  }
    _getLocalImage() async {
      _currentPost.image=null;
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
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
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imageFile != null) {
      setState(() {
        //print(croppedFile.lengthSync());
        _imageFile = croppedFile;
        isAdded = true;
      });
    }
  }
  _showImageWidget() {
    return _imageFile==null && _currentPost.image==null?Container(): ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width * 0.8,
        color: CupertinoColors.extraLightBackgroundGray,
        child: Stack(
          children: <Widget>[
            Center(
              child: _currentPost.image!=null?Image.network(_currentPost.image,fit: BoxFit.cover,) :Image.file(
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
                        _currentPost.image = null;
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

  Widget profileBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.98,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(width: 5),
          CircleAvatar(
            //minRadius: 50,
            // maxRadius: 80,
            radius: MediaQuery.of(context).size.height * 0.03,
            backgroundColor: Colors.orangeAccent,
            child: Text(
              "${user.displayName.substring(0, 2).toUpperCase()}",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${user.displayName}",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentPost = widget.post;
    _titleController.text=_currentPost.title;
    _descriptionController.text=_currentPost.description;
    if(_currentPost.image!=null){
      isAdded=true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            heroTag: "editpost",
            largeTitle: Text("Edit Post"),
            trailing: CupertinoButton(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  "Save",
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
                    _savePost();
                  }
                }),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder(
                future: getUser(widget.post.userid,false),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.done) {
                    print(snap);
                    user = snap.data;
                    return profileBar();
                  } else {
                    return Container();
                  }
                }),
          ),
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
      ),
    );
  }
}
