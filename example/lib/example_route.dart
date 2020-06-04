// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************

import 'package:flutter/widgets.dart';

import 'pages/chat_list_demo.dart';
import 'pages/gridview_demo.dart';
import 'pages/listview_demo.dart';
import 'pages/main_page.dart';

// ignore_for_file: argument_type_not_assignable
RouteResult getRouteResult({String name, Map<String, dynamic> arguments}) {
  switch (name) {
    case 'fluttercandies://chatlist':
      return RouteResult(
        name: name,
        widget: ChatListDemo(),
        routeName: 'ChatList',
        description:
            'how to build layout(reverse=true) close to trailing when children are not full of viewport.',
      );
    case 'fluttercandies://gridview':
      return RouteResult(
        name: name,
        widget: GridViewDemo(),
        routeName: 'GridView',
        description:
            'show no more/loadmore at trailing when children are not full of viewport.',
      );
    case 'fluttercandies://listview':
      return RouteResult(
        name: name,
        widget: ListViewDemo(),
        routeName: 'ListView',
        description:
            'show no more item at trailing when children are not full of viewport.',
      );
    case 'fluttercandies://mainpage':
      return RouteResult(
        name: name,
        widget: MainPage(),
        routeName: 'MainPage',
      );
    default:
      return const RouteResult(name: 'flutterCandies://notfound');
  }
}

class RouteResult {
  const RouteResult({
    @required this.name,
    this.widget,
    this.showStatusBar = true,
    this.routeName = '',
    this.pageRouteType,
    this.description = '',
    this.exts,
  });

  /// The name of the route (e.g., "/settings").
  ///
  /// If null, the route is anonymous.
  final String name;

  /// The Widget return base on route
  final Widget widget;

  /// Whether show this route with status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  /// The extend arguments
  final Map<String, dynamic> exts;
}

enum PageRouteType {
  material,
  cupertino,
  transparent,
}
