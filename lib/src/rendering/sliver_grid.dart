import 'dart:math' as math;
import 'package:extended_list_library/extended_list_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

///
///  create by zmtzawqlp on 2019/11/23
///

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [ExtendedRenderSliverGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// See also:
///
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
class ExtendedRenderSliverGrid extends RenderSliverMultiBoxAdaptor
    with ExtendedRenderObjectMixin {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [childManager] and [gridDelegate] arguments must not be null.
  ExtendedRenderSliverGrid({
    @required RenderSliverBoxChildManager childManager,
    @required SliverGridDelegate gridDelegate,
    @required ExtendedListDelegate extendedListDelegate,
  })  : assert(gridDelegate != null),
        assert(extendedListDelegate != null),
        _gridDelegate = gridDelegate,
        _extendedListDelegate = extendedListDelegate,
        super(childManager: childManager);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverGridParentData)
      child.parentData = SliverGridParentData();
  }

  /// The delegate that controls the size and position of the children.
  SliverGridDelegate get gridDelegate => _gridDelegate;
  SliverGridDelegate _gridDelegate;
  set gridDelegate(SliverGridDelegate value) {
    assert(value != null);
    if (_gridDelegate == value) return;
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) markNeedsLayout();
    _gridDelegate = value;
  }

  ExtendedListDelegate _extendedListDelegate;

  /// A delegate that provides extensions within the [ExtendedGridView/ExtendedList/WaterfallFlow].
  @override
  ExtendedListDelegate get extendedListDelegate => _extendedListDelegate;
  set extendedListDelegate(ExtendedListDelegate value) {
    assert(value != null);
    if (_extendedListDelegate == value) {
      return;
    }
    if (_extendedListDelegate.closeToTrailing != value.closeToTrailing) {
      markNeedsLayout();
    }
    _extendedListDelegate = value;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final SliverGridParentData childParentData =
        child.parentData as SliverGridParentData;
    return childParentData.crossAxisOffset;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final SliverGridLayout layout = _gridDelegate.getLayout(constraints);

    final int firstIndex = layout.getMinChildIndexForScrollOffset(scrollOffset);
    final int targetLastIndex = targetEndScrollOffset.isFinite
        ? layout.getMaxChildIndexForScrollOffset(targetEndScrollOffset)
        : null;

    if (firstChild != null) {
      final int oldFirstIndex = indexOf(firstChild);
      final int oldLastIndex = indexOf(lastChild);
      final int leadingGarbage =
          (firstIndex - oldFirstIndex).clamp(0, childCount);
      final int trailingGarbage = targetLastIndex == null
          ? 0
          : (oldLastIndex - targetLastIndex).clamp(0, childCount);
      collectGarbage(leadingGarbage, trailingGarbage);
      //zmt
      callCollectGarbage(
        collectGarbage: extendedListDelegate?.collectGarbage,
        leadingGarbage: leadingGarbage,
        trailingGarbage: trailingGarbage,
        firstIndex: firstIndex,
        targetLastIndex: targetLastIndex,
      );
    } else {
      collectGarbage(0, 0);
    }

    final SliverGridGeometry firstChildGridGeometry =
        layout.getGeometryForChildIndex(firstIndex);
    final double leadingScrollOffset = firstChildGridGeometry.scrollOffset;
    double trailingScrollOffset = firstChildGridGeometry.trailingScrollOffset;

    if (firstChild == null) {
      if (!addInitialChild(
          index: firstIndex,
          layoutOffset: firstChildGridGeometry.scrollOffset)) {
        // There are either no children, or we are past the end of all our children.
        final double max =
            layout.computeMaxScrollOffset(childManager.childCount);
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

    RenderBox trailingChildWithLayout;

    for (int index = indexOf(firstChild) - 1; index >= firstIndex; --index) {
      final SliverGridGeometry gridGeometry =
          layout.getGeometryForChildIndex(index);
      final RenderBox child = insertAndLayoutLeadingChild(
        gridGeometry.getBoxConstraints(constraints),
      );
      final SliverGridParentData childParentData =
          child.parentData as SliverGridParentData;
      childParentData.layoutOffset = gridGeometry.scrollOffset;
      childParentData.crossAxisOffset = gridGeometry.crossAxisOffset;
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
      trailingScrollOffset =
          math.max(trailingScrollOffset, gridGeometry.trailingScrollOffset);
    }

    if (trailingChildWithLayout == null) {
      firstChild.layout(firstChildGridGeometry.getBoxConstraints(constraints));
      final SliverGridParentData childParentData =
          firstChild.parentData as SliverGridParentData;
      childParentData.layoutOffset = firstChildGridGeometry.scrollOffset;
      childParentData.crossAxisOffset = firstChildGridGeometry.crossAxisOffset;
      trailingChildWithLayout = firstChild;
    }

    for (int index = indexOf(trailingChildWithLayout) + 1;
        targetLastIndex == null || index <= targetLastIndex;
        ++index) {
      final SliverGridGeometry gridGeometry =
          layout.getGeometryForChildIndex(index);
      final BoxConstraints childConstraints =
          gridGeometry.getBoxConstraints(constraints);
      RenderBox child = childAfter(trailingChildWithLayout);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints,
            after: trailingChildWithLayout);
        if (child == null) {
          // We have run out of children.
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      assert(child != null);
      final SliverGridParentData childParentData =
          child.parentData as SliverGridParentData;
      childParentData.layoutOffset = gridGeometry.scrollOffset;
      childParentData.crossAxisOffset = gridGeometry.crossAxisOffset;
      assert(childParentData.index == index);
      trailingScrollOffset =
          math.max(trailingScrollOffset, gridGeometry.trailingScrollOffset);
    }

    final int lastIndex = indexOf(lastChild);

    assert(childScrollOffset(firstChild) <= scrollOffset);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    double estimatedTotalExtent = childManager.estimateMaxScrollOffset(
      constraints,
      firstIndex: firstIndex,
      lastIndex: lastIndex,
      leadingScrollOffset: leadingScrollOffset,
      trailingScrollOffset: trailingScrollOffset,
    );

    //zmt
    final SliverGridParentData data =
        lastChild.parentData as SliverGridParentData;
    final LastChildLayoutType lastChildLayoutType =
        extendedListDelegate?.lastChildLayoutTypeBuilder?.call(data.index) ??
            LastChildLayoutType.none;

    switch (lastChildLayoutType) {
      case LastChildLayoutType.fullCrossAxisExtent:
      case LastChildLayoutType.foot:
        data.crossAxisOffset = 0.0;
        //layout as normal constraints
        lastChild.layout(constraints.asBoxConstraints(), parentUsesSize: true);
        final size = paintExtentOf(lastChild);
        trailingScrollOffset = data.index == 0
            ? size
            : layout
                .getGeometryForChildIndex(data.index - 1)
                .trailingScrollOffset;
        if (lastChildLayoutType == LastChildLayoutType.fullCrossAxisExtent ||
            trailingScrollOffset + size >= constraints.remainingPaintExtent ||
            closeToTrailing) {
          data.layoutOffset = trailingScrollOffset;
        } else {
          data.layoutOffset = constraints.remainingPaintExtent - size;
        }
        trailingScrollOffset = data.layoutOffset + size;
        estimatedTotalExtent = trailingScrollOffset;
        break;
      case LastChildLayoutType.none:
        break;
    }

    final double result =
        handleCloseToTrailingEnd(closeToTrailing, trailingScrollOffset);
    if (result != trailingScrollOffset) {
      trailingScrollOffset = result;
      estimatedTotalExtent = result;
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    ///zmt
    ///
    if (extendedListDelegate?.viewportBuilder != null) {
      double mainAxisSpacing = 0.0;
      if (_gridDelegate is SliverGridDelegateWithFixedCrossAxisCount) {
        mainAxisSpacing =
            (_gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                .mainAxisSpacing;
      } else if (_gridDelegate is SliverGridDelegateWithMaxCrossAxisExtent) {
        mainAxisSpacing =
            (_gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent)
                .mainAxisSpacing;
      }
      callViewportBuilder(
          viewportBuilder: extendedListDelegate.viewportBuilder,
          mainAxisSpacing: mainAxisSpacing,
          getPaintExtend: (RenderBox child) {
            final SliverGridParentData childParentData =
                child.parentData as SliverGridParentData;
            final LastChildLayoutType lastChildLayoutType = extendedListDelegate
                    .lastChildLayoutTypeBuilder
                    ?.call(childParentData.index) ??
                LastChildLayoutType.none;
            if (lastChildLayoutType != LastChildLayoutType.none) {
              return paintExtentOf(child);
            }

            final SliverGridGeometry gridGeometry =
                layout.getGeometryForChildIndex(childParentData.index);
            return gridGeometry.trailingScrollOffset -
                childParentData.layoutOffset;
          });
    }

    geometry = SliverGeometry(
      scrollExtent: estimatedTotalExtent,
      paintExtent: paintExtent,
      maxPaintExtent: estimatedTotalExtent,
      cacheExtent: cacheExtent,
      // Conservative to avoid complexity.
      hasVisualOverflow: true,
    );

    // We may have started the layout while scrolled to the end, which
    // would not expose a new child.
    if (estimatedTotalExtent == trailingScrollOffset)
      childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }
}
