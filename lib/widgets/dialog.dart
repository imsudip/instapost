import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../colors.dart';

void showAlertDialog(bool blockPopup,
    {String title,
    VoidCallback cancel,
    VoidCallback confirm,
    VoidCallback backgroundReturn,
    VoidCallback physicalBackButton}) {
  BotToast.showAnimationWidget(
      clickClose: false,
      allowClick: false,
      onlyOne: true,
      crossPage: true,
      wrapAnimation: (controller, cancel, child) => BackgroundRoute(
            child: child,
            blockPopup: blockPopup,
            cancelFunc: cancel,
            physicalButtonPopCallback: () {
              physicalBackButton?.call();
            },
          ),
      wrapToastAnimation: (controller, cancel, child) => Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  cancel();
                  backgroundReturn?.call();
                },
                //The DecoratedBox here is very important,he will fill the entire parent component
                child: AnimatedBuilder(
                  builder: (_, child) => Opacity(
                    opacity: controller.value,
                    child: child,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: SizedBox.expand(),
                  ),
                  animation: controller,
                ),
              ),
              CustomOffsetAnimation(
                controller: controller,
                child: child,
              )
            ],
          ),
      toastBuilder: (cancelFunc) => CupertinoAlertDialog(
            //shape:
            //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Text('$title'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  cancelFunc();
                  cancel?.call();
                },
                highlightColor: const Color(0x55FF8A80),
                splashColor: const Color(0x99FF8A80),
                child: const Text(
                  'cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              FlatButton(
                onPressed: () {
                  cancelFunc();
                  confirm?.call();
                },
                highlightColor: Colors.greenAccent.withOpacity(0.55),
                splashColor: Colors.lightGreen[200],
                child: const Text(
                  'confirm',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
      animationDuration: Duration(milliseconds: 300));
}

class BackgroundRoute extends StatefulWidget {
  final Widget child;
  final bool blockPopup;
  final CancelFunc cancelFunc;
  final VoidCallback physicalButtonPopCallback;

  const BackgroundRoute(
      {Key key,
      this.child,
      this.blockPopup,
      this.cancelFunc,
      this.physicalButtonPopCallback})
      : super(key: key);

  @override
  _BackgroundRouteState createState() => _BackgroundRouteState();
}

class CustomOffsetAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  const CustomOffsetAnimation({Key key, this.controller, this.child})
      : super(key: key);

  @override
  _CustomOffsetAnimationState createState() => _CustomOffsetAnimationState();
}

class _CustomOffsetAnimationState extends State<CustomOffsetAnimation> {
  Tween<Offset> tweenOffset;
  Tween<double> tweenScale;

  Animation<double> animation;

  @override
  void initState() {
    tweenOffset = Tween<Offset>(
      begin: const Offset(0.0, 0.8),
      end: Offset.zero,
    );
    tweenScale = Tween<double>(begin: 0.3, end: 1.0);
    animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: widget.child,
      animation: widget.controller,
      builder: (BuildContext context, Widget child) {
        return FractionalTranslation(
            translation: tweenOffset.evaluate(animation),
            child: ClipRect(
              child: Transform.scale(
                scale: tweenScale.evaluate(animation),
                child: Opacity(
                  child: child,
                  opacity: animation.value,
                ),
              ),
            ));
      },
    );
  }
}

class _BackgroundRouteState extends State<BackgroundRoute> {
  bool _needPop = false;
  NavigatorState _navigatorState;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigatorState = Navigator.of(context);
      _navigatorState.push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => IgnorePointer(
                child: WillPopScope(
                  child: Align(),
                  onWillPop: () async {
                    if (_needPop) {
                      return true;
                    }
                    if (!widget.blockPopup) {
                      widget.physicalButtonPopCallback?.call();
                      widget.cancelFunc();
                    }
                    return false;
                  },
                ),
              )));
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _needPop = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigatorState.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
