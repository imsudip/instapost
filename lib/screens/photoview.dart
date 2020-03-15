import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';
class PhotoWidget extends StatefulWidget {
 final  String image;
  PhotoWidget({Key key,this.image}) : super(key: key);

  @override
  _PhotoWidgetState createState() => _PhotoWidgetState();
}

class _PhotoWidgetState extends State<PhotoWidget> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        //heroTag: "View image",
        middle: Text("View image"),
      ),
      child: Container(
        color: CupertinoColors.white,
         child: PhotoView(
           backgroundDecoration: BoxDecoration(
             color: CupertinoColors.white
           ),
           loadingBuilder: (context, event) => Center(child: CupertinoActivityIndicator()),
           imageProvider: CachedNetworkImageProvider(widget.image,),
            
         ),
      ),
    );
  }
}