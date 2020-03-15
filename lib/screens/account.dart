import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/colors.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:instapost/widgets/post_widget.dart';
import 'package:provider/provider.dart';

class AccountWidget extends StatefulWidget {
  final User user;
  AccountWidget({Key key, this.user}) : super(key: key);

  @override
  _AccountWidgetState createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  AuthNotifier authNotifier;
  File _imageFile;
  User _user;
  bool isAdded = false;
  TextEditingController namecontrol = TextEditingController();
  String name;
  bool iseditting = false;

  String displayname;

  _getLocalImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        maxWidth: 1000,
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: CupertinoColors.activeBlue,
            toolbarWidgetColor: white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imageFile != null && croppedFile != null) {
      setState(() {
        //print(croppedFile.lengthSync());
        _imageFile = croppedFile;
        isAdded = true;
      });
      uploadUserImage(widget.user, _imageFile, () {
        BotToast.showText(text: "Profile Picture changed");
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    if (widget.user.image != null) isAdded = true;
    _user = widget.user;
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    namecontrol.text = widget.user.displayName;
    super.initState();
    displayname=widget.user.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          heroTag: "accountmain",
          largeTitle: Text("Account"),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () {
            getUser(_user.id, false).then((value) {
              _user = value;
              setState(() {});
            });
          },
        ),
        SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              CircleAvatar(
                backgroundColor: CupertinoColors.extraLightBackgroundGray,
                backgroundImage: widget.user.image != null
                    ? CachedNetworkImageProvider(widget.user.image)
                    : null,
                radius: 55,
              ),
              authNotifier.user.uid == _user.id
                  ? CupertinoButton(
                      child: Text(
                        isAdded ? "Change Image" : "Add Image",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _getLocalImage(),
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: CupertinoColors.separator,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Display Name",
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  !iseditting
                      ? Expanded(
                          child: Text(
                          displayname,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.label.withOpacity(0.7)),
                        ))
                      : editName(),
                  authNotifier.user.uid == _user.id
                      ? CupertinoButton(
                          minSize: 0,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: Icon(
                            !iseditting ? Icons.mode_edit : Icons.check,
                            size: 20,
                            color: CupertinoColors.activeBlue,
                          ),
                          onPressed: !iseditting
                              ? () {
                                  setState(() {
                                    iseditting = true;
                                  });
                                }
                              : () {
                                  setState(() {
                                    iseditting = false;
                                  });
                                  changeUserName(authNotifier, widget.user,
                                      name, _oncomplete);
                                })
                      : CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.all(0),
                          child: Icon(
                            Icons.mode_edit,
                            size: 25,
                            color: CupertinoColors.white,
                          ),
                          onPressed: null),
                ],
              ),
              Divider(
                color: CupertinoColors.separator,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "E-mail",
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  Expanded(
                      child: Text(
                    widget.user.email,
                    textAlign: TextAlign.end,
                    style: TextStyle(color: CupertinoColors.inactiveGray),
                  )),
                  CupertinoButton(
                      minSize: 0,
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        !iseditting ? Icons.mode_edit : Icons.check,
                        size: 25,
                        color: CupertinoColors.white,
                      ),
                      onPressed: null)
                ],
              ),
              Divider(
                color: CupertinoColors.separator,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Posts",
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle,
                    )),
              )
            ],
          ),
        ),
        _user.posts != null
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return FutureBuilder(
                        future: getPost(_user
                            .posts[_user.posts.length - 1 - index]
                            .toString()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return PostWidget(snapshot.data);
                          } else
                            return Container();
                        });
                  },
                  childCount: _user.posts.length,
                ),
              )
            : SliverToBoxAdapter(
                child: Container(),
              )
      ],
    ));
  }

  Widget editName() => Expanded(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7),
        child: CupertinoTextField(
          controller: namecontrol,
          placeholder: "username",
          clearButtonMode: OverlayVisibilityMode.editing,
          maxLines: 1,
          style: TextStyle(fontSize: 18),
          onSubmitted: (value) {
            name = value;
          },
          onChanged: (value) {
            name = value;
          },
        ),
      ));

  void _oncomplete() {
    BotToast.showText(text:"Username Updated");
    setState(() {
      displayname=name;
    });
  }
}
