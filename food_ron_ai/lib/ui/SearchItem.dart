import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';

class SearchItem extends StatefulWidget {
  @override
  SearchItemState createState() => SearchItemState();
}

class SearchItemState extends State<SearchItem> {
  Widget listTileBuilder(index) {
    return ListTile(
      leading: Text(index.toString()),
    //TODO: navigate bacck to image detail page after searching and clicking on specific item logic
    // onTap: () => navigateToImageDetails(context),
    );
  }

  Widget traileAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.orange,
      child: Text(
        "F",
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget floatingSerchBar() {
    return FloatingSearchBar.builder(
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return listTileBuilder(index);
      },
      trailing: traileAvatar(),
      onChanged: (String value) {},
      onTap: () {},
      decoration: InputDecoration.collapsed(
        focusColor: Colors.black,
        hintText: "Search...",
      ),
    );
  }

  // void navigateToImageDetails(context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => ImageDetails(
  //         imageUploadResponse: null,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: Container(
        padding: EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: floatingSerchBar(),
      ),
    ));
  }
}
