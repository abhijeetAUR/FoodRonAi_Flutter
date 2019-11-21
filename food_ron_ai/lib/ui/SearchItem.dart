import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_ron_ai/CounterClass.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/model_class/SearchItemModelClass.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:food_ron_ai/bloc/SearchItemBloc.dart';

class SearchItem extends StatefulWidget {
  final ImageUploadResponse imageUploadResponse;
  SearchItem({@required this.imageUploadResponse});
  @override
  SearchItemState createState() =>
      SearchItemState(imageUploadResponse: imageUploadResponse);
}

class SearchItemState extends State<SearchItem> {
  bool _fetchingResponse = false;
  ImageUploadResponse imageUploadResponse;
  SearchItemState({@required this.imageUploadResponse});
  final authorizationToken = "96331CA0-7959-402E-8016-B7ABB3287A16";
  SearchItemResponse searchItemResponse;
  DatabaseHelper databaseHelper = DatabaseHelper();
  int savedItemCount = 0;
  List foodname;
  final SearchItemBloc _searchItemBloc = SearchItemBloc();
  List<ImageUploadMetaItems> _listSearchItemMetaData =
      List<ImageUploadMetaItems>();

  void insertMetaDataInDB(ImageUploadMetaItems imageUploadMetaItems) async {
    var result = await databaseHelper.insertImageMetaData(imageUploadMetaItems);
    print(result);
    navigateToBackToImageDetails(imageUploadResponse);
  }

  void navigateToBackToImageDetails(ImageUploadResponse imageUploadResponse) {
    Navigator.pop(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ImageDetails(
          imageUploadResponse: imageUploadResponse,
        ),
      ),
    );
  }

  capitalizeName(String name) {
    return (name[0].toUpperCase() + name.substring(1)).replaceAll('-', ' ');
  }

  callSearchItemApi() async {
    _fetchingResponse = true;
    var uri = Uri.parse(Globals.searchitem);
    Map<String, String> headers = {"authorization": authorizationToken};
    var request = http.get(uri, headers: headers);
    final response = await request;
    print(response.statusCode);

    if (response.statusCode == 200) {
      var valueSearch = SearchItemResponse.fromJson(json.decode(response.body));
      print(valueSearch);
      final count = getAdditionalItemCountFromSharedPref(valueSearch);
      count.then((itemCountForAdditionalItems) {
        if (itemCountForAdditionalItems == null) {
          saveToAdditionalMetaDB(valueSearch);
          storeItemCountInSharedPred(valueSearch);
        }
        if (itemCountForAdditionalItems < valueSearch.itemCount) {
          //TODO: Save additional data to db
        } else {
          getAllRecordsFromDb();
        }
        setState(() {
          _fetchingResponse = false;
        });
      });
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<int> getAdditionalItemCountFromSharedPref(
      SearchItemResponse valueSearch) async {
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
    for (var item in result) {
      ImageUploadMetaItems imageUploadMetaItems =
          ImageUploadMetaItems.fromJson(item);
      imageUploadMetaItems.itemMetaId = imageUploadResponse.itemMetaId;
      imageUploadMetaItems.datetime = imageUploadResponse.datetime;
      imageUploadMetaItems.serve = item['serveSize'];
      _listSearchItemMetaData.add(imageUploadMetaItems);
    }
    print(_listSearchItemMetaData);
    _searchItemBloc.changeListOnBlocFromDB(_listSearchItemMetaData);
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
    if (valueSearch.items.isNotEmpty) {
      await databaseHelper.insertItemInAdditionalMetaData(
          valueSearch.items[savedItemCount].metadata);
      if (savedItemCount != (valueSearch.itemCount - 1)) {
        savedItemCount += 1;
        saveToAdditionalMetaDB(valueSearch);
      } else {
        getAllRecordsFromDb();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    callSearchItemApi();
    //TODO: get data from db and dont call api each time
  }

  @override
  void dispose() {
    _searchItemBloc.dispose();
    super.dispose();
  }

  Widget listTileBuilder(
      AsyncSnapshot<List<ImageUploadMetaItems>> snapshot, index) {
    return GridTile(
      child: GestureDetector(
        onTap: () {
          insertMetaDataInDB(snapshot.data[index]);
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(width: 1, color: Color(0xFFFFe2e2e2)),
            )),
            width: MediaQuery.of(context).size.width,
            height: 50,
            margin: EdgeInsets.only(right: 15, left: 15),
            padding: EdgeInsets.only(left: 14, right: 10, top: 15),
            child: Text(
              "\u{1F35B}  " + (capitalizeName(snapshot.data[index].name)),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            )),
      ),
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

  Widget searchitemStreamBuilder() {
    return StreamBuilder<List<ImageUploadMetaItems>>(
        stream: _searchItemBloc.searchItemStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageUploadMetaItems>> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return floatingSerchBar(snapshot);
        });
  }

  Widget floatingSerchBar(AsyncSnapshot<List<ImageUploadMetaItems>> snapshot) {
    return FloatingSearchBar.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return listTileBuilder(snapshot, index);
      },
      onChanged: (String value) {
        if (value.isNotEmpty) {
          var result = _listSearchItemMetaData
              .where((f) => f.name.trim().startsWith('$value'))
              .toList();
          _searchItemBloc.changeListOnBlocFromDB(
              result.isEmpty ? _listSearchItemMetaData : result);
        } else {
          _searchItemBloc.changeListOnBlocFromDB(_listSearchItemMetaData);
        }
      },
      onTap: () {
        print("search");
      },
      decoration: InputDecoration.collapsed(
        hintText: "Search...",
        hintStyle: TextStyle(
            fontSize: 14.0, color: Colors.grey, fontFamily: 'HelveticaNeue'),
      ),
    );
  }

  scaffoldBody() {
    return SafeArea(
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
            Expanded(child: searchitemStreamBuilder()),
          ],
        ),
      ),
    );
  }

  indicator() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: new Color.fromRGBO(241, 241, 241, 0.5)),
      child: Center(
        child: Container(
          height: (MediaQuery.of(context).size.width / 6).roundToDouble(),
          width: (MediaQuery.of(context).size.width / 6).roundToDouble(),
          color: Colors.green,
          child: SpinKitWave(
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _fetchingResponse ? indicator() : scaffoldBody());
  }
}
