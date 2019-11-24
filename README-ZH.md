# extended_list

扩展(ListView/GridView) 支持追踪列表元素回收/Viewport的index改变,最后一个元素为loadmore/no more元素时候的特殊布局,以及针对reverse为true时候布局靠近底部的布局。

[![pub package](https://img.shields.io/pub/v/extended_list.svg)](https://pub.dartlang.org/packages/extended_list) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: [English](README.md) | 中文简体

- [extended_list](#extendedlist)
  - [使用](#%e4%bd%bf%e7%94%a8)
  - [列表Item回收](#%e5%88%97%e8%a1%a8item%e5%9b%9e%e6%94%b6)
  - [ViewportBuilder](#viewportbuilder)
  - [LastChildLayoutTypeBuilder](#lastchildlayouttypebuilder)
  - [CloseToTrailing](#closetotrailing)

## 使用

* 在pubspec.yaml中增加库引用
  
```yaml

dependencies:
  extended_list: any

```  
* 导入库
  
```dart

  import 'package:extended_list/extended_list.dart';
  
```

## 列表Item回收

支持列表Item回收回调，你可以在这个时刻回收一些内存，比如图片的内存缓存。

```dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                collectGarbage: (List<int> garbages) {
                print("collect garbage : $garbages");
                },),
```

## ViewportBuilder

追踪进入Viewport的列表Item的index（即你看到的可视区域，并不包括缓存距离）

```dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                viewportBuilder: (int firstIndex, int lastIndex) {
                print("viewport : [$firstIndex,$lastIndex]");
                }),
```

## LastChildLayoutTypeBuilder

为最后一个元素创建特殊布局，这主要是用在将最后一个元素作为loadmore/no more的时候。

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_list/gridview.gif)

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_list/listview.gif)

```dart
        enum LastChildLayoutType {
        /// 普通的
        none,

        /// 将最后一个元素绘制在最大主轴Item之后，并且使用横轴大小最为layout size
        /// 主要使用在[ExtendedGridView] and [WaterfallFlow]中，最后一个元素作为loadmore/no more元素的时候。
        fullCrossAxisExtend,

        /// 将最后一个child绘制在trailing of viewport，并且使用横轴大小最为layout size
        /// 这种常用于最后一个元素作为loadmore/no more元素，并且列表元素没有充满整个viewport的时候
        /// 如果列表元素充满viewport，那么效果跟fullCrossAxisExtend一样
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

当reverse设置为true的时候，布局会变成如下。常用于聊天列表，新的会话会被插入0的位置，但是当会话没有充满viewport的时候，下面的布局不是我们想要的。

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

为了解决这个问题，你可以设置 closeToTrailing 为true, 布局将变成如下
该属性同时支持[ExtendedGridView],[ExtendedList],[WaterfallFlow]。
当然如果reverse如果不为ture，你设置这个属性依然会生效，没满viewport的时候布局会紧靠trailing

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