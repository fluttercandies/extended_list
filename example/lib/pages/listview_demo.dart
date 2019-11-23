import 'dart:math';
import 'package:example/common/widget_builder.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:extended_list/extended_list.dart';
///
///  create by zmtzawqlp on 2019/11/23
///

@FFRoute(
  name: "fluttercandies://listview",
  routeName: "ListView",
  description:
      "show no more item at trailing when children are not full of viewport.",
)
class ListViewDemo extends StatefulWidget {
  @override
  _ListViewDemoState createState() => _ListViewDemoState();
}

class _ListViewDemoState extends State<ListViewDemo> {
  final List<Color> colors = List<Color>();
  int length = 5;
  bool get hasMore => length < 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ListView"),
      ),
      body: ExtendedListView.builder(
        extendedListDelegate: ExtendedListDelegate(

            /// follow max child trailing layout offset and layout with full cross axis extend
            /// last child as loadmore item/no more item in [GridView] and [WaterfallFlow]
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
            }),
        //itemExtent: 50.0,
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
            height: 50.0,
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
