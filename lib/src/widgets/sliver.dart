import 'package:extended_list/src/rendering/sliver_fixed_extend_list.dart';
import 'package:extended_list/src/rendering/sliver_grid.dart';
import 'package:extended_list/src/rendering/sliver_list.dart';
import 'package:extended_list_library/extended_list_library.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A sliver that places multiple box children in a linear array along the main
/// axis.
///
/// Each child is forced to have the [SliverConstraints.crossAxisExtent] in the
/// cross axis but determines its own main axis extent.
///
/// [ExtendedSliverList] determines its scroll offset by "dead reckoning" because
/// children outside the visible part of the sliver are not materialized, which
/// means [ExtendedSliverList] cannot learn their main axis extent. Instead, newly
/// materialized children are placed adjacent to existing children.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=ORiTTaVY6mM}
///
/// If the children have a fixed extent in the main axis, consider using
/// [ExtendedSliverFixedExtentList] rather than [ExtendedSliverList] because
/// [ExtendedSliverFixedExtentList] does not need to perform layout on its children to
/// obtain their extent in the main axis and is therefore more efficient.
///
/// {@macro flutter.widgets.sliverChildDelegate.lifecycle}
///
/// See also:
///
///  * [ExtendedSliverFixedExtentList], which is more efficient for children with
///    the same extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [ExtendedSliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
///  * [ExtendedSliverGrid], which places its children in arbitrary positions.
class ExtendedSliverList extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children in a linear array.
  const ExtendedSliverList({
    Key key,
    @required SliverChildDelegate delegate,
    this.extendedListDelegate,
  }) : super(key: key, delegate: delegate);

  /// A delegate that controls the last child layout of the children within the [ExtendedGridView/ExtendedList/WaterfallFlow].
  final ExtendedListDelegate extendedListDelegate;

  @override
  ExtendedRenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context;
    return ExtendedRenderSliverList(
      childManager: element,
      extendedListDelegate: extendedListDelegate,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ExtendedRenderSliverList renderObject) {
    renderObject.extendedListDelegate = extendedListDelegate;
  }
}

/// A sliver that places multiple box children with the same main axis extent in
/// a linear array.
///
/// [ExtendedSliverFixedExtentList] places its children in a linear array along the main
/// axis starting at offset zero and without gaps. Each child is forced to have
/// the [itemExtent] in the main axis and the
/// [SliverConstraints.crossAxisExtent] in the cross axis.
///
/// [ExtendedSliverFixedExtentList] is more efficient than [ExtendedSliverList] because
/// [ExtendedSliverFixedExtentList] does not need to perform layout on its children to
/// obtain their extent in the main axis.
///
/// {@tool sample}
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows an infinite number of items in varying shades of blue:
///
/// ```dart
/// SliverFixedExtentList(
///   itemExtent: 50.0,
///   delegate: SliverChildBuilderDelegate(
///     (BuildContext context, int index) {
///       return Container(
///         alignment: Alignment.center,
///         color: Colors.lightBlue[100 * (index % 9)],
///         child: Text('list item $index'),
///       );
///     },
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@macro flutter.widgets.sliverChildDelegate.lifecycle}
///
/// See also:
///
///  * [SliverPrototypeExtentList], which is similar to [ExtendedSliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
///  * [SliverFillViewport], which determines the [itemExtent] based on
///    [SliverConstraints.viewportMainAxisExtent].
///  * [ExtendedSliverList], which does not require its children to have the same
///    extent in the main axis.
class ExtendedSliverFixedExtentList extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children with the same main axis extent
  /// in a linear array.
  const ExtendedSliverFixedExtentList({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.itemExtent,
    this.extendedListDelegate,
  }) : super(key: key, delegate: delegate);

  /// The extent the children are forced to have in the main axis.
  final double itemExtent;

  /// A delegate that controls the last child layout of the children within the [ExtendedGridView/ExtendedList/WaterfallFlow].
  final ExtendedListDelegate extendedListDelegate;
  @override
  ExtendedRenderSliverFixedExtentList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context;
    return ExtendedRenderSliverFixedExtentList(
      childManager: element,
      itemExtent: itemExtent,
      extendedListDelegate: extendedListDelegate,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ExtendedRenderSliverFixedExtentList renderObject) {
    renderObject.itemExtent = itemExtent;
    renderObject.extendedListDelegate = extendedListDelegate;
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [ExtendedSliverGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// The main axis direction of a grid is the direction in which it scrolls; the
/// cross axis direction is the orthogonal direction.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=ORiTTaVY6mM}
///
/// {@tool sample}
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows twenty boxes in a pretty teal grid:
///
/// ```dart
/// SliverGrid(
///   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
///     maxCrossAxisExtent: 200.0,
///     mainAxisSpacing: 10.0,
///     crossAxisSpacing: 10.0,
///     childAspectRatio: 4.0,
///   ),
///   delegate: SliverChildBuilderDelegate(
///     (BuildContext context, int index) {
///       return Container(
///         alignment: Alignment.center,
///         color: Colors.teal[100 * (index % 9)],
///         child: Text('grid item $index'),
///       );
///     },
///     childCount: 20,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@macro flutter.widgets.sliverChildDelegate.lifecycle}
///
/// See also:
///
///  * [ExtendedSliverList], which places its children in a linear array.
///  * [ExtendedSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [ExtendedSliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
class ExtendedSliverGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const ExtendedSliverGrid({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.gridDelegate,
    this.extendedListDelegate,
  }) : super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new GridView.count], the equivalent constructor for [GridView] widgets.
  ExtendedSliverGrid.count({
    Key key,
    @required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
    this.extendedListDelegate,
  })  : gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        super(key: key, delegate: SliverChildListDelegate(children));

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new GridView.extent], the equivalent constructor for [GridView] widgets.
  ExtendedSliverGrid.extent({
    Key key,
    @required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
    this.extendedListDelegate,
  })  : gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        super(key: key, delegate: SliverChildListDelegate(children));

  /// The delegate that controls the size and position of the children.
  final SliverGridDelegate gridDelegate;

  /// A delegate that controls the last child layout of the children within the [ExtendedGridView/ExtendedList/WaterfallFlow].
  final ExtendedListDelegate extendedListDelegate;
  @override
  ExtendedRenderSliverGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context;
    return ExtendedRenderSliverGrid(
      childManager: element,
      gridDelegate: gridDelegate,
      extendedListDelegate: extendedListDelegate,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ExtendedRenderSliverGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
    renderObject.extendedListDelegate = extendedListDelegate;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return super.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        gridDelegate
            .getLayout(constraints)
            .computeMaxScrollOffset(delegate.estimatedChildCount);
  }
}
