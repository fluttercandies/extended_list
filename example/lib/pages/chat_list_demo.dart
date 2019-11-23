import 'dart:math';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:extended_list/extended_list.dart';

///
///  create by zmtzawqlp on 2019/11/23
///

@FFRoute(
  name: "fluttercandies://chatlist",
  routeName: "ChatList",
  description:
      "how to build layout(reverse=true) close to trailing when children are not full of viewport.",
)
class ChatListDemo extends StatefulWidget {
  @override
  _ChatListDemoState createState() => _ChatListDemoState();
}

class _ChatListDemoState extends State<ChatListDemo> {
  final List<Color> colors = List<Color>();
  final List<String> sessions = ["I'm session", "I'm session", "I'm session"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatList"),
      ),
      body: ExtendedListView.builder(
        //itemExtent: 50.0,
        reverse: true,

        /// when reverse property of List is true, layout is as following.
        /// it likes chat list, and new session will insert to zero index
        /// but it's not right when items are not full of viewport.
        ///
        ///      trailing
        /// -----------------
        /// |               |
        /// |               |
        /// |     item2     |
        /// |     item1     |
        /// |     item0     |
        /// -----------------
        ///      leading
        ///
        /// to solve it, you could set closeToTrailing to true, layout is as following.
        /// support [ExtendedGridView],[ExtendedList],[WaterfallFlow]
        /// it works not only reverse is true.
        ///
        ///      trailing
        /// -----------------
        /// |     item2     |
        /// |     item1     |
        /// |     item0     |
        /// |               |
        /// |               |
        /// -----------------
        ///      leading
        ///
        extendedListDelegate: ExtendedListDelegate(closeToTrailing: true),
        itemBuilder: (c, index) {
          final Color color = getRandomColor(index);
          List<Widget> children = [
            Expanded(
              flex: 5,
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: getRandomColor(index)),
                alignment: Alignment.center,
                child: Text(
                  "${sessions[index]} $index",
                  style: TextStyle(
                      color: color.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ),
            Expanded(flex: 2, child: Container()),
          ];
          if (index % 2 == 0) {
            children = children.reversed.toList();
          }
          return Row(children: children);
        },
        itemCount: sessions.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            sessions.insert(0, "I'm session");
          });
        },
        child: Icon(Icons.add),
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
