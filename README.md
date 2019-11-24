# extended_list

extended list(ListView/GridView) support track collect garbage children/viewport indexes, build lastChild as special child in the case that it is loadmore/no more item and enable to layout close to trailing.

[![pub package](https://img.shields.io/pub/v/extended_list.svg)](https://pub.dartlang.org/packages/extended_list) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: English | [中文简体](README-ZH.md)

- [extended_list](#extendedlist)
  - [Use](#use)
  - [CollectGarbage](#collectgarbage)
  - [ViewportBuilder](#viewportbuilder)
  - [LastChildLayoutTypeBuilder](#lastchildlayouttypebuilder)
  - [CloseToTrailing](#closetotrailing)

## Use

* add library to your pubspec.yaml
  
```yaml

dependencies:
  extended_list: any

```  
* import library in dart file
  
```dart

  import 'package:extended_list/extended_list.dart';
  
```

## CollectGarbage

track the indexes are collect, you can collect garbage at that monment(for example Image cache)

```dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                collectGarbage: (List<int> garbages) {
                print("collect garbage : $garbages");
                },),
```

## ViewportBuilder

track the indexes go into the viewport, it's not include cache extent.

```dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                viewportBuilder: (int firstIndex, int lastIndex) {
                print("viewport : [$firstIndex,$lastIndex]");
                }),
```

## LastChildLayoutTypeBuilder

build lastChild as special child in the case that it is loadmore/no more item.

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_list/gridview.gif)

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_list/listview.gif)

```dart
        enum LastChildLayoutType {
        /// as default child
        none,

        /// follow max child trailing layout offset and layout with full cross axis extend
        /// last child as loadmore item/no more item in [ExtendedGridView] and [WaterfallFlow]
        /// with full cross axis extend
        fullCrossAxisExtend,

        /// as foot at trailing and layout with full cross axis extend
        /// show no more item at trailing when children are not full of viewport
        /// if children is full of viewport, it's the same as fullCrossAxisExtend
        foot,
        }

      ExtendedListView.builder(
        extendedListDelegate: ExtendedListDelegate(
            lastChildLayoutTypeBuilder: (index) => index == length
                ? LastChildLayoutType.foot
                : LastChildLayoutType.none,
            ),
```

## CloseToTrailing

when reverse property of List is true, layout is as following.
it likes chat list, and new session will insert to zero index.
but it's not right when items are not full of viewport.

```
     trailing
-----------------
|               |
|               |
|     item2     |
|     item1     |
|     item0     |
-----------------
     leading
```     

to solve it, you could set closeToTrailing to true, layout is as following.
support [ExtendedGridView],[ExtendedList],[WaterfallFlow].
and it also works when reverse is flase, layout will close to trailing.

```
     trailing
-----------------
|     item2     |
|     item1     |
|     item0     |
|               |
|               |
-----------------
     leading
```     

```dart
      ExtendedListView.builder(
        reverse: true,
        extendedListDelegate: ExtendedListDelegate(closeToTrailing: true),
```