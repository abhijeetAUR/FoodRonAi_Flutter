import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:food_ron_ai/model_class/SearchItemModelClass.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:http/http.dart' as http;


class SearchItem extends StatefulWidget {
  @override
  SearchItemState createState() => SearchItemState();
}

class SearchItemState extends State<SearchItem> {
  final authorizationToken = "96331CA0-7959-402E-8016-B7ABB3287A16";
  SearchItemResponse searchItemResponse;

  Widget listTileBuilder(index) {
    return GridTile(
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          padding: EdgeInsets.only(left: 24, right: 24, top: 15),
          child: Text(index.toString() + "\t Item")),
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

  callSearchItemApi() async {
    var uri = Uri.parse(Globals.searchitem);
    Map<String, String> headers = {"authorization": authorizationToken};
    var request = http.get(uri, headers: headers);
    final response = await request;
    print(response.statusCode);

    if (response.statusCode == 200) {
      var value = SearchItemResponse.fromJson(json.decode(response.body));
print(value);
    } else {
      throw Exception('Failed to load post');
    }
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
  void initState() {
    super.initState();
    callSearchItemApi();
  }

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
