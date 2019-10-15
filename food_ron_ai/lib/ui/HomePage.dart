import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();

  @override
  void dispose() {
    // TODO: implement dispose
    _imageDataBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Globals.topAppBar,
      // body: FoodItems(),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<ImageMetaData>>(
            stream: _imageDataBloc.imageListStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<ImageMetaData>> snapshot) {
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Hero(
                        tag: snapshot.data[index].foodname,
                        child: Material(
                          child: InkWell(
                            onTap: () {},
                            child: GridTile(
                              footer: Container(
                                color: Colors.black26,
                                child: ListTile(
                                  leading: Text(
                                    snapshot.data[index].foodname,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              child: Image.asset(
                                'images/pizza.jpg'
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            },
          )
        ],
      ),
    );
  }
}

// class FoodItems extends StatefulWidget {
//   @override
//   _FoodItemsState createState() => _FoodItemsState();
// }

// class _FoodItemsState extends State<FoodItems> {
//   final imageList = [
//     {"name": "pizza", "imageurl": "images/pizza.jpg"},
//     {"name": "burger", "imageurl": "images/burger.jpg"},
//     {"name": "icecream", "imageurl": "images/icecream.jpg"},
//     {"name": "panipuri", "imageurl": "images/pizza.jpg"},
//     {"name": "sabji", "imageurl": "images/pizza.jpg"},
//     {"name": "roti", "imageurl": "images/burger.jpg"},
//     {"name": "fries", "imageurl": "images/icecream.jpg"},
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate:
//           SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//       itemCount: imageList.length,
//       itemBuilder: (BuildContext context, int index) {
//         return ImageItem(
//           imageName: imageList[index]['name'],
//           imageUrl: imageList[index]['imageurl'],
//         );
//       },
//     );
//   }
// }

// class ImageItem extends StatelessWidget {
//   final imageName;
//   final imageUrl;

//   ImageItem({this.imageName, this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Hero(
//         tag: imageName,
//         child: Material(
//           child: InkWell(
//             onTap: () {},
//             child: GridTile(
//               footer: Container(
//                 color: Colors.black26,
//                 child: ListTile(
//                   leading: Text(
//                     imageName,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//               child: Image.asset(
//                 imageUrl,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
