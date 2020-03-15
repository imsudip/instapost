import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/colors.dart';
import 'package:instapost/model/post.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:instapost/notifier/post_notifier.dart';
import 'package:instapost/screens/account.dart';
import 'package:instapost/screens/detail.dart';
import 'package:instapost/screens/post_form.dart';
import 'package:flutter/material.dart';
import 'package:instapost/widgets/dialog.dart';
import 'package:instapost/widgets/post_widget.dart';
import 'package:provider/provider.dart';
CupertinoTabController tabController=CupertinoTabController();
class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  User user;
  @override
  void initState() {
    PostNotifier postNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    getPosts(postNotifier);
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    user = authNotifier.fullUser;
    
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    PostNotifier postNotifier = Provider.of<PostNotifier>(context);
    //var stream = getPosts();
    _refreshList() {
      getPosts(postNotifier);
    }

    print("building Feed");
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          title: Text("Home"),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.add),
          title: Text("Add"),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          title: Text("Account"),
        )
      ]),
      controller: tabController,
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoPageScaffold(
            child: CustomScrollView(
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  leading: CupertinoButton(
                      padding: EdgeInsets.only(bottom: 3),
                      onPressed: () {
                        // showAlertDialog(
                        //   false,
                        //   title: "Do you want to log out?",
                        //   confirm: () => signout(authNotifier),
                        // );
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text("Do you want to log out?"),
                            actions: <Widget>[
                              CupertinoButton(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                        color: CupertinoColors.activeGreen),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    signout(authNotifier);
                                  }),
                              CupertinoButton(
                                  child: Text("No",
                                      style: TextStyle(
                                          color:
                                              CupertinoColors.destructiveRed)),
                                  onPressed: () => Navigator.of(context).pop()),
                            ],
                          ),
                        );
                      },
                      // signout(authNotifier),
                      child: Icon(Icons.power_settings_new)),
                  middle: Text(
                    "InstaPost",
                    style: TextStyle(
                        fontSize: 25, fontFamily: "Kaushan", color: black),
                  ),
                  // trailing: CupertinoButton(
                  //     padding: EdgeInsets.only(bottom: 3),
                  //     onPressed: () {
                  //       _refreshList();

                  //     },
                  //     // signout(authNotifier),
                  //     child: Icon(Icons.refresh)),
                  largeTitle: Text("Home",
                      style: TextStyle(
                          //fontSize: 35,
                          color: black,
                          fontWeight: FontWeight.w700)),
                ),
                CupertinoSliverRefreshControl(
                  onRefresh: () {
                    BotToast.showText(text: "Feed Refresed..");
                    return _refreshList();
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    
                    (BuildContext context, int index) {
                      return PostWidget(postNotifier.postList[index]);
                    },
                    childCount: postNotifier.postList.length,
                    addAutomaticKeepAlives: true
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                  ),
                )
              ],
            ),
          );
        } else if (index == 1)
          return PostForm(
            isUpdating: false,
            user: authNotifier.user,
          );
        else if (index == 2)
          return AccountWidget(
            user: user,
          );
      },
      //  backgroundColor: Colors.transparent,
    );
  }
}
