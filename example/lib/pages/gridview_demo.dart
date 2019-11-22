import 'dart:math';

///
///  create by zmtzawqlp on 2019/11/22
///
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:extended_list/extended_list.dart';

@FFRoute(
  name: "fluttercandies://gridview",
  routeName: "grid view",
  description: "show how to build waterfall flow in CustomScrollview.",
)
class GridViewDemo extends StatefulWidget {
  @override
  _GridViewDemoState createState() => _GridViewDemoState();
}

class _GridViewDemoState extends State<GridViewDemo> {
  final List<Color> colors = List<Color>();
  int length = 5;
  bool get hasMore => length < 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("GridView"),
      ),
      body: ExtendedGridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        extendedListDelegate: ExtendedListDelegate(
          lastChildLayoutTypeBuilder: (index) => index == length
              ? LastChildLayoutType.foot
              : LastChildLayoutType.none,
        ),
        itemBuilder: (c, index) {
          if (index == length) {
            return _buildLastWidget(context);
          }
          final Color color = getRandomColor(index);

          return Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: getRandomColor(index)),
            alignment: Alignment.center,
            child: Text(
              "$index",
              style: TextStyle(
                  color: color.computeLuminance() < 0.5
                      ? Colors.white
                      : Colors.black),
            ),
          );
        },
        itemCount: length + 1,
      ),
    );
  }

  Widget _buildLastWidget(BuildContext context) {
    if (hasMore) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          length += 30;
        });
      });
    }

    return Container(
        alignment: Alignment.center,
        color: Colors.grey.withOpacity(0.2),
        margin: EdgeInsets.only(top: 5.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Text(
          hasMore ? "loading..." : "no more",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ));
  }

  getRandomColor(int index) {
    if (index >= colors.length) {
      colors.add(Color.fromARGB(255, Random.secure().nextInt(255),
          Random.secure().nextInt(255), Random.secure().nextInt(255)));
    }

    return colors[index];
  }
}
