import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/colors.dart';
import 'package:instapost/model/post.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:instapost/notifier/post_notifier.dart';
import 'package:instapost/screens/account.dart';
import 'package:instapost/screens/edit_post.dart';
import 'package:instapost/screens/photoview.dart';
import 'package:instapost/screens/post_form.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';

List<User> userList = [];

class PostWidget extends StatefulWidget {
  final Post post;
  PostWidget(this.post, {Key key}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  User user;
  String dateTime;

  @override
  void initState() {
    //getUser(widget.post.userid, user);
    user = findUser(widget.post.userid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: EdgeInsets.all(5),
      color: white,
      child: Container(
        // height: 150,
        child: Column(
          children: <Widget>[
            FutureBuilder(
                future: getUser(widget.post.userid, true),
                builder: (context, snap) {
                  if (snap.hasData) {
                    //print(snap);
                    user = snap.data;
                    return profileBar();
                  } else {
                    return Container();
                  }
                }),
            SizedBox(
              height: 5,
            ),
            widget.post.image != null ? buildImage() : Container(),
            SizedBox(
              height: 10,
            ),
            buildTitle(),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget profileBar() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
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
            backgroundImage: CachedNetworkImageProvider(user.image),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                  maintainState: true,
                  //fullscreenDialog: true,
                  builder: (context) => AccountWidget(
                        user: user,
                      ))),
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
                  Text(
                    "${formatTime(widget.post.createdAt.millisecondsSinceEpoch)}",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          )),
          authNotifier.user.uid == widget.post.userid
              ? GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(right: 7),
                    child: Icon(
                      Icons.more_vert,
                      color: CupertinoColors.black,
                    ),
                  ),
                  onTap: () => showCupertinoModalPopup (
                          context: context,
                          builder: (context) =>  CupertinoActionSheet(
                            //title: Text(""),
                            actions: <Widget>[
                              
                              CupertinoButton(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(CupertinoIcons.pencil,color: CupertinoColors.activeBlue,),
                                       SizedBox(width: 8,),
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                            color: CupertinoColors.activeBlue,fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    
                                    Navigator.of(context).pop();
                                    edit();
                                  }),
                              CupertinoButton(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(CupertinoIcons.delete_solid,color: CupertinoColors.destructiveRed,),
                                       SizedBox(width: 8,),
                                      Text(
                                        "Delete",
                                        style: TextStyle(
                                            color: CupertinoColors.destructiveRed,fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    deletePost(widget.post, postDeleted);
                                  }),
                            ],
                            cancelButton: CupertinoButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: CupertinoColors.destructiveRed,fontSize: 20,fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    
                                  }),
                          ),
                        ),
                  //  BotToast.showAttachedWidget(
                  //     attachedBuilder: (_) => Card(
                  //           color: CupertinoColors.extraLightBackgroundGray
                  //               .withOpacity(0.85),
                  //           elevation: 5,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12)),
                  //           child: Padding(
                  //             padding: EdgeInsets.all(7),
                  //             child: Container(
                  //                 // height: 120,
                  //                 width: 90,
                  //                 child: Column(
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: <Widget>[
                  //                     Flexible(
                  //                         child: GestureDetector(
                  //                       onTap: () => edit(),
                  //                       child: Padding(
                  //                         padding:
                  //                             EdgeInsets.symmetric(vertical: 7),
                  //                         child: Text(
                  //                           "Edit",
                  //                           style: TextStyle(
                  //                               color: CupertinoColors.black,
                  //                               fontSize: 17,
                  //                               fontWeight: FontWeight.w400),
                  //                         ),
                  //                       ),
                  //                     )),
                  //                     Flexible(
                  //                         child: GestureDetector(
                  //                       onTap: () => deletePost(
                  //                           widget.post, postDeleted),
                  //                       child: Padding(
                  //                         padding:
                  //                             EdgeInsets.symmetric(vertical: 7),
                  //                         child: Text(
                  //                           "Delete",
                  //                           style: TextStyle(
                  //                               color: CupertinoColors.black,
                  //                               fontSize: 17,
                  //                               fontWeight: FontWeight.w400),
                  //                         ),
                  //                       ),
                  //                     )),
                  //                   ],
                  //                 )),
                  //           ),
                  //         ),
                  //     duration: Duration(seconds: 3),
                  //     verticalOffset: 0,
                  //     horizontalOffset: 15,
                  //     preferDirection: PreferDirection.leftCenter,
                  //     onlyOne: true,
                  //     allowClick: true,
                  //     ignoreContentClick: false,
                  //     target: details.globalPosition),
                )
              : Container()
        ],
      ),
    );
  }

  edit() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    if (authNotifier.user.uid == widget.post.userid) {
      // postNotifier.currentPost = widget.post;
      print("true");
      Navigator.of(context).push(CupertinoPageRoute(
        maintainState: true,
        //fullscreenDialog: true,
        builder: (context) => EditPost(
          post: widget.post,
        ),
      ));
    }
  }

  Widget buildTitle() => Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 7),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${widget.post.title}",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: widget.post.image == null ? 30 : 18,
                  fontWeight: FontWeight.w500),
            ),
            widget.post.description != null
                ? Text(
                    "${widget.post.description}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: widget.post.image == null ? 22 : 15,
                        fontWeight: FontWeight.w300),
                  )
                : Container(),
          ],
        ),
      );
  Widget buildImage() => GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(
            maintainState: true,
            //fullscreenDialog: true,
            //fullscreenDialog: true,
            builder: (context) => PhotoWidget(
              image: widget.post.image,
            ),
          ));
        },
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.8,
          // height: MediaQuery.of(context).size.height * 0.6,
          child: CachedNetworkImage(
            imageUrl: widget.post.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: Text(
                "loading...",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),
        ),
      );

  postDeleted() {
    PostNotifier postNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    postNotifier.deletePost(widget.post);
    BotToast.showText(text: "Post deleted");
    setState(() {});
  }
}
