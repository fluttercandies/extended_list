# extended_list

[![pub package](https://img.shields.io/pub/v/extended_list.svg)](https://pub.dartlang.org/packages/extended_list) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_list)](https://github.com/fluttercandies/extended_list/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: [English](README.md) | 中文简体

扩展(ListView/GridView) 支持追踪列表元素回收/Viewport 的 index 改变,最后一个元素为 loadmore/no more 元素时候的特殊布局,以及针对 reverse 为 true 时候布局靠近底部的布局。

[Web demo for ExtendedList](https://fluttercandies.github.io/extended_list/)

- [extended_list](#extended_list)
  - [使用](#使用)
  - [列表元素回收](#列表元素回收)
  - [ViewportBuilder](#viewportbuilder)
  - [LastChildLayoutTypeBuilder](#lastchildlayouttypebuilder)
  - [CloseToTrailing](#closetotrailing)

## 使用

- 在 pubspec.yaml 中增加库引用

```yaml
dependencies:
  extended_list: any
```

- 导入库

```dart

  import 'package:extended_list/extended_list.dart';

```

## 列表元素回收

追踪列表元素回收，你可以在这个时刻回收一些内存，比如图片的内存缓存。

[更多详情](https://github.com/fluttercandies/extended_image/blob/e1577bc4d0b57c725110a9d886703b98a72772b5/example/lib/pages/photo_view_demo.dart#L91)

```dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                collectGarbage: (List<int> garbages) {
                print("collect garbage : $garbages");
                },),
```

## ViewportBuilder

追踪进入 Viewport 的列表元素的 index（即你看到的可视区域，并不包括缓存距离）

```dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                viewportBuilder: (int firstIndex, int lastIndex) {
                print("viewport : [$firstIndex,$lastIndex]");
                }),
```

## LastChildLayoutTypeBuilder

为最后一个元素创建特殊布局，这主要是用在将最后一个元素作为 loadmore/no more 的时候。

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_list/gridview.gif)

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_list/listview.gif)

```dart
        enum LastChildLayoutType {
        /// 普通的
        none,

        /// 将最后一个元素绘制在最大主轴Item之后，并且使用横轴大小最为layout size
        /// 主要使用在[ExtendedGridView] and [WaterfallFlow]中，最后一个元素作为loadmore/no more元素的时候。
        fullCrossAxisExtent,

        /// 将最后一个child绘制在trailing of viewport，并且使用横轴大小最为layout size
        /// 这种常用于最后一个元素作为loadmore/no more元素，并且列表元素没有充满整个viewport的时候
        /// 如果列表元素充满viewport，那么效果跟fullCrossAxisExtent一样
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

当 reverse 设置为 true 的时候，布局会变成如下。常用于聊天列表，新的会话会被插入 0 的位置，但是当会话没有充满 viewport 的时候，下面的布局不是我们想要的。

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

为了解决这个问题，你可以设置 closeToTrailing 为 true, 布局将变成如下
该属性同时支持[ExtendedGridView],[ExtendedList],[WaterfallFlow]。
当然如果 reverse 如果不为 ture，你设置这个属性依然会生效，没满 viewport 的时候布局会紧靠 trailing

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
## ☕️Buy me a coffee

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)
