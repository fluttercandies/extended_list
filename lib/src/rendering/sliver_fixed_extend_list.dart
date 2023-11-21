import 'dart:math' as math;
import 'package:extended_list_library/extended_list_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

///
///  create by zmtzawqlp on 2019/11/23
///

/// A sliver that contains multiple box children that have the same extent in
/// the main axis.
///
/// [ExtendedRenderSliverFixedExtentBoxAdaptor] places its children in a linear array
/// along the main axis. Each child is forced to have the [itemExtent] in the
/// main axis and the [SliverConstraints.crossAxisExtent] in the cross axis.
///
/// Subclasses should override [itemExtent] to control the size of the children
/// in the main axis. For a concrete subclass with a configurable [itemExtent],
/// see [ExtendedRenderSliverFixedExtentList].
///
/// [ExtendedRenderSliverFixedExtentBoxAdaptor] is more efficient than
/// [RenderSliverList] because [ExtendedRenderSliverFixedExtentBoxAdaptor] does not need
/// to perform layout on its children to obtain their extent in the main axis.
///
/// See also:
///
///  * [ExtendedRenderSliverFixedExtentList], which has a configurable [itemExtent].
///  * [RenderSliverFillViewport], which determines the [itemExtent] based on
///    [SliverConstraints.viewportMainAxisExtent].
///  * [RenderSliverFillRemaining], which determines the [itemExtent] based on
///    [SliverConstraints.remainingPaintExtent].
///  * [RenderSliverList], which does not require its children to have the same
///    extent in the main axis.
abstract class ExtendedRenderSliverFixedExtentBoxAdaptor
    extends RenderSliverMultiBoxAdaptor with ExtendedRenderObjectMixin {
  /// Creates a sliver that contains multiple box children that have the same
  /// extent in the main axis.
  ///
  /// The [childManager] argument must not be null.
  ExtendedRenderSliverFixedExtentBoxAdaptor({
    required RenderSliverBoxChildManager childManager,
    required ExtendedListDelegate extendedListDelegate,
  })  : _extendedListDelegate = extendedListDelegate,
        super(childManager: childManager);

  ExtendedListDelegate _extendedListDelegate;

  /// A delegate that provides extensions within the [ExtendedGridView/ExtendedList/WaterfallFlow].
  @override
  ExtendedListDelegate get extendedListDelegate => _extendedListDelegate;
  set extendedListDelegate(ExtendedListDelegate value) {
    if (_extendedListDelegate == value) {
      return;
    }
    if (_extendedListDelegate.closeToTrailing != value.closeToTrailing) {
      markNeedsLayout();
    }
    _extendedListDelegate = value;
  }

  /// The main-axis extent of each item.
  double get itemExtent;

  /// The layout offset for the child with the given index.
  ///
  /// This function is given the [itemExtent] as an argument to avoid
  /// recomputing [itemExtent] repeatedly during layout.
  ///
  /// By default, places the children in order, without gaps, starting from
  /// layout offset zero.
  @protected
  double indexToLayoutOffset(double itemExtent, int index) =>
      itemExtent * index;

  /// The minimum child index that is visible at the given scroll offset.
  ///
  /// This function is given the [itemExtent] as an argument to avoid
  /// recomputing [itemExtent] repeatedly during layout.
  ///
  /// By default, returns a value consistent with the children being placed in
  /// order, without gaps, starting from layout offset zero.
  @protected
  int getMinChildIndexForScrollOffset(double scrollOffset, double itemExtent) {
    if (itemExtent > 0.0) {
      final double actual = scrollOffset / itemExtent;
      final int round = actual.round();
      if ((actual - round).abs() < precisionErrorTolerance) {
        return round;
      }
      return actual.floor();
    }
    return 0;
  }

  /// The maximum child index that is visible at the given scroll offset.
  ///
  /// This function is given the [itemExtent] as an argument to avoid
  /// recomputing [itemExtent] repeatedly during layout.
  ///
  /// By default, returns a value consistent with the children being placed in
  /// order, without gaps, starting from layout offset zero.
  @protected
  int getMaxChildIndexForScrollOffset(double scrollOffset, double itemExtent) {
    if (itemExtent > 0.0) {
      final double actual = scrollOffset / itemExtent - 1;
      final int round = actual.round();
      if (_isWithinPrecisionErrorTolerance(actual, round)) {
        return math.max(0, round);
      }
      return math.max(0, actual.ceil());
    }
    return 0;
  }

  /// Called to estimate the total scrollable extents of this object.
  ///
  /// Must return the total distance from the start of the child with the
  /// earliest possible index to the end of the child with the last possible
  /// index.
  ///
  /// By default, defers to [RenderSliverBoxChildManager.estimateMaxScrollOffset].
  ///
  /// See also:
  ///
  ///  * [computeMaxScrollOffset], which is similar but must provide a precise
  ///    value.
  @protected
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    return childManager.estimateMaxScrollOffset(
      constraints,
      firstIndex: firstIndex,
      lastIndex: lastIndex,
      leadingScrollOffset: leadingScrollOffset,
      trailingScrollOffset: trailingScrollOffset,
    );
  }

  /// Called to obtain a precise measure of the total scrollable extents of this
  /// object.
  ///
  /// Must return the precise total distance from the start of the child with
  /// the earliest possible index to the end of the child with the last possible
  /// index.
  ///
  /// This is used when no child is available for the index corresponding to the
  /// current scroll offset, to determine the precise dimensions of the sliver.
  /// It must return a precise value. It will not be called if the
  /// [childManager] returns an infinite number of children for positive
  /// indices.
  ///
  /// By default, multiplies the [itemExtent] by the number of children reported
  /// by [RenderSliverBoxChildManager.childCount].
  ///
  /// See also:
  ///
  ///  * [estimateMaxScrollOffset], which is similar but may provide inaccurate
  ///    values.
  @protected
  double computeMaxScrollOffset(
      SliverConstraints constraints, double itemExtent) {
    return childManager.childCount * itemExtent;
  }

  int _calculateLeadingGarbage(int firstIndex) {
    RenderBox? walker = firstChild;
    int leadingGarbage = 0;
    while (walker != null && indexOf(walker) < firstIndex) {
      leadingGarbage += 1;
      walker = childAfter(walker);
    }
    return leadingGarbage;
  }

  int _calculateTrailingGarbage(int? targetLastIndex) {
    RenderBox? walker = lastChild;
    int trailingGarbage = 0;
    while (walker != null && indexOf(walker) > targetLastIndex!) {
      trailingGarbage += 1;
      walker = childBefore(walker);
    }
    return trailingGarbage;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double itemExtent = this.itemExtent;

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final BoxConstraints childConstraints = constraints.asBoxConstraints(
      minExtent: itemExtent,
      maxExtent: itemExtent,
    );

    final int firstIndex =
        getMinChildIndexForScrollOffset(scrollOffset, itemExtent);
    final int? targetLastIndex = targetEndScrollOffset.isFinite
        ? getMaxChildIndexForScrollOffset(targetEndScrollOffset, itemExtent)
        : null;

    if (firstChild != null) {
      final int leadingGarbage = _calculateLeadingGarbage(firstIndex);
      final int trailingGarbage = targetLastIndex != null
          ? _calculateTrailingGarbage(targetLastIndex)
          : 0;
      collectGarbage(leadingGarbage, trailingGarbage);
      //zmt
      callCollectGarbage(
        collectGarbage: extendedListDelegate.collectGarbage,
        leadingGarbage: leadingGarbage,
        trailingGarbage: trailingGarbage,
        firstIndex: firstIndex,
        targetLastIndex: targetLastIndex,
      );
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      if (!addInitialChild(
          index: firstIndex,
          layoutOffset: indexToLayoutOffset(itemExtent, firstIndex))) {
        // There are either no children, or we are past the end of all our children.
        final double max;
        if (firstIndex <= 0) {
          max = 0.0;
        } else {
          max = computeMaxScrollOffset(constraints, itemExtent);
        }
        geometry = SliverGeometry(
          scrollExtent: max,
          maxPaintExtent: max,
        );
        childManager.didFinishLayout();
        return;
      }
    }

    // zmt
    handleCloseToTrailingBegin(closeToTrailing);

    RenderBox? trailingChildWithLayout;

    for (int index = indexOf(firstChild!) - 1; index >= firstIndex; --index) {
      final RenderBox? child = insertAndLayoutLeadingChild(childConstraints);
      if (child == null) {
        // Items before the previously first child are no longer present.
        // Reset the scroll offset to offset all items prior and up to the
        // missing item. Let parent re-layout everything.
        geometry = SliverGeometry(scrollOffsetCorrection: index * itemExtent);
        return;
      }
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(itemExtent, index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild!.layout(childConstraints);
      final SliverMultiBoxAdaptorParentData childParentData =
          firstChild!.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset =
          indexToLayoutOffset(itemExtent, firstIndex);
      trailingChildWithLayout = firstChild;
    }

    double estimatedMaxScrollOffset = double.infinity;
    for (int index = indexOf(trailingChildWithLayout!) + 1;
        targetLastIndex == null || index <= targetLastIndex;
        ++index) {
      RenderBox? child = childAfter(trailingChildWithLayout!);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints,
            after: trailingChildWithLayout);
        if (child == null) {
          // We have run out of children.
          estimatedMaxScrollOffset = index * itemExtent;
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset =
          indexToLayoutOffset(itemExtent, childParentData.index!);
    }

    final int lastIndex = indexOf(lastChild!);
    final double leadingScrollOffset =
        indexToLayoutOffset(itemExtent, firstIndex);
    double trailingScrollOffset =
        indexToLayoutOffset(itemExtent, lastIndex + 1);

    ///zmt
    final double result =
        handleCloseToTrailingEnd(closeToTrailing, trailingScrollOffset);
    if (result != trailingScrollOffset) {
      trailingScrollOffset = result;
      estimatedMaxScrollOffset = result;
    }

    ///zmt
    final bool lastChildIsFoot = (extendedListDelegate
                .lastChildLayoutTypeBuilder
                ?.call(indexOf(lastChild!)) ??
            LastChildLayoutType.none) ==
        LastChildLayoutType.foot;
    if (lastChildIsFoot) {
      //layout as normal constraints
      lastChild!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
      final double paintExtend = paintExtentOf(lastChild!);
      trailingScrollOffset = childScrollOffset(lastChild!)! + paintExtend;
      if (trailingScrollOffset < constraints.remainingPaintExtent) {
        final SliverMultiBoxAdaptorParentData childParentData =
            lastChild!.parentData as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset =
            constraints.remainingPaintExtent - paintExtend;
        trailingScrollOffset = constraints.remainingPaintExtent;
      }
      estimatedMaxScrollOffset = trailingScrollOffset;
    }

    assert(firstIndex == 0 ||
        childScrollOffset(firstChild!)! - scrollOffset <=
            precisionErrorTolerance);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild!) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    estimatedMaxScrollOffset = math.min(
      estimatedMaxScrollOffset,
      estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      ),
    );

    double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    final int? targetLastIndexForPaint = targetEndScrollOffsetForPaint.isFinite
        ? getMaxChildIndexForScrollOffset(
            targetEndScrollOffsetForPaint, itemExtent)
        : null;

    ///zmt
    callViewportBuilder(
        viewportBuilder: extendedListDelegate.viewportBuilder,
        getPaintExtend: (RenderBox? child) {
          final LastChildLayoutType lastChildLayoutType = extendedListDelegate
                  .lastChildLayoutTypeBuilder
                  ?.call(indexOf(child!)) ??
              LastChildLayoutType.none;
          if (lastChildLayoutType != LastChildLayoutType.none) {
            return paintExtentOf(child!);
          }
          return itemExtent;
        });

    // fix hittest
    if (closeToTrailing) {
      paintExtent += closeToTrailingDistance;
    }

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: (targetLastIndexForPaint != null &&
              lastIndex >= targetLastIndexForPaint) ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == trailingScrollOffset)
      childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }
}

/// A sliver that places multiple box children with the same main axis extent in
/// a linear array.
///
/// [ExtendedRenderSliverFixedExtentList] places its children in a linear array along
/// the main axis starting at offset zero and without gaps. Each child is forced
/// to have the [itemExtent] in the main axis and the
/// [SliverConstraints.crossAxisExtent] in the cross axis.
///
/// [ExtendedRenderSliverFixedExtentList] is more efficient than [RenderSliverList]
/// because [ExtendedRenderSliverFixedExtentList] does not need to perform layout on its
/// children to obtain their extent in the main axis.
///
/// See also:
///
///  * [RenderSliverList], which does not require its children to have the same
///    extent in the main axis.
///  * [RenderSliverFillViewport], which determines the [itemExtent] based on
///    [SliverConstraints.viewportMainAxisExtent].
///  * [RenderSliverFillRemaining], which determines the [itemExtent] based on
///    [SliverConstraints.remainingPaintExtent].
class ExtendedRenderSliverFixedExtentList
    extends ExtendedRenderSliverFixedExtentBoxAdaptor {
  /// Creates a sliver that contains multiple box children that have a given
  /// extent in the main axis.
  ///
  /// The [childManager] argument must not be null.
  ExtendedRenderSliverFixedExtentList(
      {required RenderSliverBoxChildManager childManager,
      required double itemExtent,
      required ExtendedListDelegate extendedListDelegate})
      : _itemExtent = itemExtent,
        super(
          childManager: childManager,
          extendedListDelegate: extendedListDelegate,
        );

  @override
  double get itemExtent => _itemExtent;
  double _itemExtent;
  set itemExtent(double value) {
    if (_itemExtent == value) {
      return;
    }
    _itemExtent = value;
    markNeedsLayout();
  }
}

bool _isWithinPrecisionErrorTolerance(double actual, int round) {
  return (actual - round).abs() < precisionErrorTolerance;
}
