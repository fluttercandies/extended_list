import 'dart:math';
import 'package:example/common/widget_builder.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:extended_list/extended_list.dart';
///
///  create by zmtzawqlp on 2019/11/23
///

@FFRoute(
  name: "fluttercandies://gridview",
  routeName: "GridView",
  description:
      "show no more/loadmore at trailing when children are not full of viewport.",
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
          /// follow max child trailing layout offset and layout with full cross axis extend
          /// last child as loadmore item/no more item in [ExtendedGridView] and [WaterfallFlow]
          /// with full cross axis extend
          //  LastChildLayoutType.fullCrossAxisExtend,

          /// as foot at trailing and layout with full cross axis extend
          /// show no more item at trailing when children are not full of viewport
          /// if children is full of viewport, it's the same as fullCrossAxisExtend
          //  LastChildLayoutType.foot,
          lastChildLayoutTypeBuilder: (index) => index == length
              ? LastChildLayoutType.foot
              : LastChildLayoutType.none,
          collectGarbage: (List<int> garbages) {
            print("collect garbage : $garbages");
          },
          viewportBuilder: (int firstIndex, int lastIndex) {
            print("viewport : [$firstIndex,$lastIndex]");
          },
        ),
        itemBuilder: (c, index) {
          if (index == length) {
            if (hasMore) {
              //delay 2 seconds,see loadmore clearly
              Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  length += 30;
                });
              });
            }
            return buildLastWidget(context: context, hasMore: hasMore);
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

  getRandomColor(int index) {
    if (index >= colors.length) {
      colors.add(Color.fromARGB(255, Random.secure().nextInt(255),
          Random.secure().nextInt(255), Random.secure().nextInt(255)));
    }

    return colors[index];
  }
}
