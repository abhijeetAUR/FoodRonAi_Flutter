import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/model_class/SearchItemModelClass.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchItem extends StatefulWidget {
  final ImageUploadResponse imageUploadResponse;
  SearchItem({@required this.imageUploadResponse});
  @override
  SearchItemState createState() =>
      SearchItemState(imageUploadResponse: imageUploadResponse);
}

class SearchItemState extends State<SearchItem> {
  ImageUploadResponse imageUploadResponse;
  SearchItemState({@required this.imageUploadResponse});
  final authorizationToken = "96331CA0-7959-402E-8016-B7ABB3287A16";
  SearchItemResponse searchItemResponse;
  DatabaseHelper databaseHelper = DatabaseHelper();
  int savedItemCount = 0;
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
      backgroundColor: Colors.green,
      child: Text(
        "S",
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "SEARCH",
          style: TextStyle(
              color: Color.fromRGBO(45, 46, 51, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  callSearchItemApi() async {
    var uri = Uri.parse(Globals.searchitem);
    Map<String, String> headers = {"authorization": authorizationToken};
    var request = http.get(uri, headers: headers);
    final response = await request;
    print(response.statusCode);

    if (response.statusCode == 200) {
      var valueSearch = SearchItemResponse.fromJson(json.decode(response.body));
      print(valueSearch);
      final count = getAdditionalItemCountFromSharedPref();
      count.then((itemCountForAdditionalItems) {
        if (itemCountForAdditionalItems > valueSearch.itemCount) {
          final result = storeItemCountInSharedPred(valueSearch);
          result.then((status) {
            if (status) {
              saveToAdditionalMetaDB(valueSearch);
            }
          });
        } else {
          getAllRecordsFromDb();
        }
      });
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<int> getAdditionalItemCountFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final itemCount = prefs.getInt('itemCountForAdditionalItem');
    return itemCount;
  }

  getAllRecordsFromDb() async {
    var result = await databaseHelper.getAllAdditionalRecords();
    print(result);
    appendItemMetaIdToEachRecord(result);
  }

  appendItemMetaIdToEachRecord(List<dynamic> result) {
    List<ImageUploadMetaItems> lstSerchedItemMetaData =
        List<ImageUploadMetaItems>();
    for (var item in result) {
      ImageUploadMetaItems imageUploadMetaItems =
          ImageUploadMetaItems.fromJson(item);
      imageUploadMetaItems.itemMetaId = imageUploadResponse.itemMetaId;
      imageUploadMetaItems.datetime = imageUploadResponse.datetime;
      imageUploadMetaItems.serve = item['serveSize'];
      lstSerchedItemMetaData.add(imageUploadMetaItems);
    }
    print(lstSerchedItemMetaData);
    //Create bloc and append this list to ui
  }

  Future<bool> storeItemCountInSharedPred(
      SearchItemResponse valueSearch) async {
    var itemStoredInSharedPref = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    itemStoredInSharedPref =
        await prefs.setInt('itemCountForAdditionalItem', valueSearch.itemCount);
    return itemStoredInSharedPref;
  }

  saveToAdditionalMetaDB(SearchItemResponse valueSearch) async {
    var result = -1;
    if (valueSearch.items.isNotEmpty) {
      result = await databaseHelper.insertItemInAdditionalMetaData(
          valueSearch.items[savedItemCount].metadata);
      if (savedItemCount != (valueSearch.itemCount - 1)) {
        savedItemCount += 1;
        saveToAdditionalMetaDB(valueSearch);
      } else {
        getAllRecordsFromDb();
      }
    }
  }

  Widget floatingSerchBar() {
    return FloatingSearchBar.builder(
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return listTileBuilder(index);
      },
      trailing: traileAvatar(),
      onChanged: (String value) {
        print(value);
      },
      onTap: () {
        print("search");
      },
      decoration: InputDecoration.collapsed(
        focusColor: Colors.green,
        hintText: "Search...",
      ),
    );
  }

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
        child: Column(
          children: <Widget>[
            title(),
            SizedBox(height: 10),
            Expanded(child: floatingSerchBar()),
          ],
        ),
      ),
    ));
  }
}
