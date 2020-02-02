import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example_route.dart';
import 'example_route_helper.dart';

///
///  create by zmtzawqlp on 2019/11/23
///

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExtendedList Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "fluttercandies://mainpage",
      onGenerateRoute: (RouteSettings settings) {
        var routeName = settings.name;
        //when refresh web, route will as following
        //   /
        //   /fluttercandies:
        //   /fluttercandies:/
        //   /fluttercandies://mainpage
    
        if (kIsWeb && routeName.startsWith('/')) {
          routeName = routeName.replaceFirst('/', '');
        }

        var routeResult =
            getRouteResult(name: routeName, arguments: settings.arguments);

        if (routeResult.showStatusBar != null ||
            routeResult.routeName != null) {
          settings = FFRouteSettings(
              arguments: settings.arguments,
              name: routeName,
              isInitialRoute: settings.isInitialRoute,
              routeName: routeResult.routeName,
              showStatusBar: routeResult.showStatusBar);
        }

        var page = routeResult.widget ??
            getRouteResult(
                    name: 'fluttercandies://mainpage',
                    arguments: settings.arguments)
                .widget;

        final platform = Theme.of(context).platform;
        switch (routeResult.pageRouteType) {
          case PageRouteType.material:
            return MaterialPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.cupertino:
            return CupertinoPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.transparent:
            return FFTransparentPageRoute(
                settings: settings,
                pageBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation) =>
                    page);
          default:
            return platform == TargetPlatform.iOS
                ? CupertinoPageRoute(settings: settings, builder: (c) => page)
                : MaterialPageRoute(settings: settings, builder: (c) => page);
        }
      },
    );
  }
}
