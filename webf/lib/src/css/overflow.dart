/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Element;
import 'package:flutter/gestures.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType { auto, visible, hidden, scroll, clip }

typedef HandlePointerCallback = void Function(WebFScrollable scrollable);

// Styles which need to copy from outer scrolling box to inner scrolling content box.
List<String> _scrollingContentBoxCopyStyles = [
  DISPLAY,
  LINE_HEIGHT,
  TEXT_ALIGN,
  WHITE_SPACE,
  FLEX_DIRECTION,
  FLEX_WRAP,
  ALIGN_CONTENT,
  ALIGN_ITEMS,
  ALIGN_SELF,
  JUSTIFY_CONTENT,
  COLOR,
  TEXT_DECORATION_LINE,
  TEXT_DECORATION_COLOR,
  TEXT_DECORATION_STYLE,
  FONT_WEIGHT,
  FONT_STYLE,
  FONT_FAMILY,
  FONT_SIZE,
  LETTER_SPACING,
  WORD_SPACING,
  TEXT_SHADOW,
  TEXT_OVERFLOW,
  LINE_CLAMP,
];

enum ScrollableDirection { x, y }

mixin CSSOverflowMixin on RenderStyle {
  WebFScrollable? _domScrollableX;
  WebFScrollable? _domScrollableY;

  final Map<RenderObjectElement, WebFScrollable> _widgetScrollableX = {};
  final Map<RenderObjectElement, WebFScrollable> _widgetScrollableY = {};

  @pragma('vm:prefer-inline')
  bool hasScrollableX() {
    if (target.managedByFlutterWidget) {
      return everyWidgetRenderBox((renderObjectElement, renderObject) {
        return _widgetScrollableX[renderObjectElement] != null;
      });
    }

    return _domScrollableX != null;
  }

  void clearScrollableX() {
    if (target.managedByFlutterWidget) {
      widgetRenderObjects.forEach((renderObjectElement, renderObject) {
        _widgetScrollableX[renderObjectElement]?.position?.dispose();
      });
      _widgetScrollableX.clear();
      return;
    }

    _domScrollableX?.position?.dispose();
    _domScrollableX = null;
  }

  void _setUpScrollable(ScrollableDirection direction, ScrollListener listener) {
    if (target.managedByFlutterWidget) {
      everyWidgetRenderBox((renderObjectElement, renderBox) {
        WebFScrollable scrollable;
        var map = direction == ScrollableDirection.x ? _widgetScrollableX : _widgetScrollableY;
        CSSOverflowType overflowType = direction == ScrollableDirection.x ? overflowX : overflowY;
        if (!map.containsKey(renderObjectElement)) {
          scrollable = WebFScrollable(
              axisDirection: direction == ScrollableDirection.x ? AxisDirection.right : AxisDirection.down,
              scrollListener: listener,
              overflowType: overflowType,
              currentView: currentFlutterView);
          map[renderObjectElement!] = scrollable;
        } else {
          scrollable = map[renderObjectElement]!;
        }

        RenderBoxModel renderBoxModel = widgetRenderObjects[renderObjectElement]!;
        if (direction == ScrollableDirection.x) {
          renderBoxModel.scrollOffsetX = scrollable.position;
        } else {
          renderBoxModel.scrollOffsetY = scrollable.position;
        }

        renderBoxModel.scrollListener = listener;
        renderBoxModel.scrollablePointerListener = _scrollablePointerListener;

        // Reset canDrag by overflow because hidden is can't drag.
        bool canDrag = overflowType != CSSOverflowType.hidden;
        scrollable.overflowType = overflowType;
        scrollable.setCanDrag(canDrag);
        return true;
      });
      return;
    }

    CSSOverflowType overflowType = direction == ScrollableDirection.x ? overflowX : overflowY;
    WebFScrollable scrollable = WebFScrollable(
        axisDirection: direction == ScrollableDirection.x ? AxisDirection.right : AxisDirection.down,
        scrollListener: listener,
        overflowType: overflowType,
        currentView: currentFlutterView);

    if (direction == ScrollableDirection.x) {
      domRenderBoxModel!.scrollOffsetX = scrollable.position;
      _domScrollableX = scrollable;
    } else {
      domRenderBoxModel!.scrollOffsetY = scrollable.position;
      _domScrollableY = scrollable;
    }

    bool canDrag = overflowType != CSSOverflowType.hidden;
    scrollable.overflowType = overflowType;
    scrollable.setCanDrag(canDrag);
    domRenderBoxModel!.scrollListener = listener;
    domRenderBoxModel!.scrollablePointerListener = _scrollablePointerListener;
  }

  void setUpScrollableX(ScrollListener listener) {
    _setUpScrollable(ScrollableDirection.x, listener);
  }

  void setUpScrollableY(ScrollListener listener) {
    _setUpScrollable(ScrollableDirection.y, listener);
  }

  void clearScrollableY() {
    if (target.managedByFlutterWidget) {
      widgetRenderObjects.forEach((renderObjectElement, renderObject) {
        _widgetScrollableY[renderObjectElement]?.position?.dispose();
      });
      _widgetScrollableY.clear();
    }

    _domScrollableY?.position?.dispose();
    _domScrollableY = null;
  }

  @override
  void disposeScrollable() {
    for (var scrollable in _widgetScrollableX.values) {
      scrollable.position?.dispose();
    }

    for (var scrollable in _widgetScrollableY.values) {
      scrollable.position?.dispose();
    }

    _widgetScrollableX.clear();
    _widgetScrollableY.clear();

    _domScrollableX?.position?.dispose();
    _domScrollableY?.position?.dispose();

    _domScrollableX = null;
    _domScrollableY = null;
  }

  void handleScrollable(HandlePointerCallback callback) {
    if (target.managedByFlutterWidget) {
      for (var scrollable in _widgetScrollableX.values) {
        callback(scrollable);
      }

      for (var scrollable in _widgetScrollableY.values) {
        callback(scrollable);
      }

      return;
    }

    if (_domScrollableX != null) {
      callback(_domScrollableX!);
    }
    if (_domScrollableY != null) {
      callback(_domScrollableY!);
    }
  }

  void _scrollablePointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      handleScrollable((scrollable) {
        scrollable.handlePointerDown(event);
      });
    } else if (event is PointerSignalEvent) {
      handleScrollable((scrollable) {
        scrollable.handlePinterSignal(event);
      });
    } else if (event is PointerPanZoomStartEvent) {
      handleScrollable((scrollable) {
        scrollable.handlePointerPanZoomStart(event);
      });
    }
  }

  @override
  CSSOverflowType get overflowX => _overflowX ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowX;

  set overflowX(CSSOverflowType? value) {
    if (_overflowX == value) return;
    _overflowX = value;
  }

  @override
  CSSOverflowType get overflowY => _overflowY ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowY;

  set overflowY(CSSOverflowType? value) {
    if (_overflowY == value) return;
    _overflowY = value;
  }

  // As specified, except with visible/clip computing to auto/hidden (respectively)
  // if one of overflow-x or overflow-y is neither visible nor clip.
  // https://www.w3.org/TR/css-overflow-3/#propdef-overflow-x
  @override
  CSSOverflowType get effectiveOverflowX {
    if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    if (overflowX == CSSOverflowType.clip && overflowY != CSSOverflowType.clip) {
      return CSSOverflowType.hidden;
    }
    return overflowX;
  }

  // As specified, except with visible/clip computing to auto/hidden (respectively)
  // if one of overflow-x or overflow-y is neither visible nor clip.
  // https://www.w3.org/TR/css-overflow-3/#propdef-overflow-y
  @override
  CSSOverflowType get effectiveOverflowY {
    if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    if (overflowY == CSSOverflowType.clip && overflowX != CSSOverflowType.clip) {
      return CSSOverflowType.hidden;
    }
    return overflowY;
  }

  static CSSOverflowType resolveOverflowType(String definition) {
    switch (definition) {
      case HIDDEN:
        return CSSOverflowType.hidden;
      case SCROLL:
        return CSSOverflowType.scroll;
      case AUTO:
        return CSSOverflowType.auto;
      case CLIP:
        return CSSOverflowType.clip;
      case VISIBLE:
      default:
        return CSSOverflowType.visible;
    }
  }
}

mixin ElementOverflowMixin on ElementBase {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  void updateRenderBoxModelWithOverflowX(ScrollListener scrollListener) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this.updateRenderBoxModelWithOverflowX');
    }
    if (renderStyle.isSelfRenderSliverListLayout()) {
      if (managedByFlutterWidget) throw FlutterError('css display sliver not supported in with flutter widget adapter');
      renderStyle.getSelfRenderBoxValue((renderBoxModel, _) {
        RenderSliverListLayout sliverListLayout = renderBoxModel as RenderSliverListLayout;
        sliverListLayout.scrollOffsetX =
            sliverListLayout.axis == Axis.horizontal ? sliverListLayout.scrollable.position : null;
      });
    } else if (renderStyle.hasRenderBox()) {
      CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
      switch (overflowX) {
        case CSSOverflowType.clip:
          renderStyle.clearScrollableX();
          break;
        case CSSOverflowType.hidden:
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          // If the render has been offset when previous overflow is auto or scroll, _scrollableX should not reset.
          renderStyle.setUpScrollableX(scrollListener);
          break;
        case CSSOverflowType.visible:
        default:
          renderStyle.clearScrollableX();
          break;
      }
    }
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  void updateRenderBoxModelWithOverflowY(ScrollListener scrollListener) {
    if (renderStyle.isSelfRenderSliverListLayout()) {
      renderStyle.getSelfRenderBoxValue((renderBoxModel, _) {
        RenderSliverListLayout sliverListLayout = renderBoxModel as RenderSliverListLayout;
        sliverListLayout.scrollOffsetY =
            sliverListLayout.axis == Axis.vertical ? sliverListLayout.scrollable.position : null;
      });
    } else if (renderStyle.hasRenderBox()) {
      CSSOverflowType overflowY = renderStyle.effectiveOverflowY;
      switch (overflowY) {
        case CSSOverflowType.clip:
          renderStyle.clearScrollableY();
          break;
        case CSSOverflowType.hidden:
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          // If the render has been offset when previous overflow is auto or scroll, _scrollableY should not reset.
          renderStyle.setUpScrollableY(scrollListener);
          break;
        case CSSOverflowType.visible:
        default:
          renderStyle.clearScrollableY();
          break;
      }
    }
  }

  void scrollingContentBoxStyleListener(String property, String? original, String present, {String? baseHref}) {
    if (!renderStyle.hasRenderBox()) return;

    CSSRenderStyle? scrollingContentRenderStyle = renderStyle.getScrollContentRenderStyle();
    // Sliver content has no multi scroll content box.
    if (scrollingContentRenderStyle == null) return;

    switch (property) {
      case DISPLAY:
        scrollingContentRenderStyle.display = renderStyle.display;
        break;
      case LINE_HEIGHT:
        scrollingContentRenderStyle.lineHeight = renderStyle.lineHeight;
        break;
      case TEXT_ALIGN:
        scrollingContentRenderStyle.textAlign = renderStyle.textAlign;
        break;
      case WHITE_SPACE:
        scrollingContentRenderStyle.whiteSpace = renderStyle.whiteSpace;
        break;
      case FLEX_DIRECTION:
        scrollingContentRenderStyle.flexDirection = renderStyle.flexDirection;
        break;
      case FLEX_WRAP:
        scrollingContentRenderStyle.flexWrap = renderStyle.flexWrap;
        break;
      case ALIGN_CONTENT:
        scrollingContentRenderStyle.alignContent = renderStyle.alignContent;
        break;
      case ALIGN_ITEMS:
        scrollingContentRenderStyle.alignItems = renderStyle.alignItems;
        break;
      case ALIGN_SELF:
        scrollingContentRenderStyle.alignSelf = renderStyle.alignSelf;
        break;
      case JUSTIFY_CONTENT:
        scrollingContentRenderStyle.justifyContent = renderStyle.justifyContent;
        break;
      case COLOR:
        scrollingContentRenderStyle.color = renderStyle.color;
        break;
      case TEXT_DECORATION_LINE:
        scrollingContentRenderStyle.textDecorationLine = renderStyle.textDecorationLine;
        break;
      case TEXT_DECORATION_COLOR:
        scrollingContentRenderStyle.textDecorationColor = renderStyle.textDecorationColor;
        break;
      case TEXT_DECORATION_STYLE:
        scrollingContentRenderStyle.textDecorationStyle = renderStyle.textDecorationStyle;
        break;
      case FONT_WEIGHT:
        scrollingContentRenderStyle.fontWeight = renderStyle.fontWeight;
        break;
      case FONT_STYLE:
        scrollingContentRenderStyle.fontStyle = renderStyle.fontStyle;
        break;
      case FONT_FAMILY:
        scrollingContentRenderStyle.fontFamily = renderStyle.fontFamily;
        break;
      case FONT_SIZE:
        scrollingContentRenderStyle.fontSize = renderStyle.fontSize;
        break;
      case LETTER_SPACING:
        scrollingContentRenderStyle.letterSpacing = renderStyle.letterSpacing;
        break;
      case WORD_SPACING:
        scrollingContentRenderStyle.wordSpacing = renderStyle.wordSpacing;
        break;
      case TEXT_SHADOW:
        scrollingContentRenderStyle.textShadow = renderStyle.textShadow;
        break;
      case TEXT_OVERFLOW:
        scrollingContentRenderStyle.textOverflow = renderStyle.textOverflow;
        break;
      case LINE_CLAMP:
        scrollingContentRenderStyle.lineClamp = renderStyle.lineClamp;
        break;
    }
  }

  // Update renderBox according to overflow value.
  void updateOverflowRenderBox() {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this.updateOverflowRenderBox');
    }
    CSSOverflowType effectiveOverflowY = renderStyle.effectiveOverflowY;
    CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;

    // @TODO: optimize scroll performance for flutter widget adapter mode.
    if (renderStyle.isSelfRenderLayoutBox() && !managedByFlutterWidget) {
      // Create two repaintBoundary for scroll container if any direction is scrollable.
      bool shouldScrolling =
          (effectiveOverflowX == CSSOverflowType.auto || effectiveOverflowX == CSSOverflowType.scroll) ||
              (effectiveOverflowY == CSSOverflowType.auto || effectiveOverflowY == CSSOverflowType.scroll);

      if (shouldScrolling) {
        _attachScrollingContentBox();
      } else {
        _detachScrollingContentBox();
      }
    }
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  void updateScrollingContentBox() {
    _detachScrollingContentBox();
    _attachScrollingContentBox();
  }

  // Create two repaintBoundary for an overflow scroll container.
  // Outer repaintBoundary avoid repaint of parent and sibling renderObjects when scrolling.
  // Inner repaintBoundary avoid repaint of child renderObjects when scrolling.
  void _attachScrollingContentBox() {
    assert(!managedByFlutterWidget);
    RenderLayoutBox outerLayoutBox = renderStyle.domRenderBoxModel as RenderLayoutBox;
    RenderLayoutBox? scrollingContentBox = outerLayoutBox.renderScrollingContent;
    if (scrollingContentBox != null) {
      return;
    }

    Element element = this as Element;
    // If outer scrolling box already has children in the case of element already attached,
    // move them into the children of inner scrolling box.
    List<RenderBox> children = outerLayoutBox.detachChildren();

    RenderLayoutBox renderScrollingContent = element.createScrollingContentLayout();
    renderScrollingContent.addAll(children);

    outerLayoutBox.add(renderScrollingContent);
    element.style.addStyleChangeListener(scrollingContentBoxStyleListener);

    // Manually copy already set filtered styles to the renderStyle of scrollingContentLayoutBox.
    _scrollingContentBoxCopyStyles.forEach((String styleProperty) {
      scrollingContentBoxStyleListener(styleProperty, null, '');
    });
  }

  void _detachScrollingContentBox() {
    assert(!managedByFlutterWidget);
    RenderLayoutBox outerLayoutBox = renderStyle.domRenderBoxModel as RenderLayoutBox;
    RenderLayoutBox? scrollingContentBox = outerLayoutBox.renderScrollingContent;
    if (scrollingContentBox == null) return;

    List<RenderBox> children = scrollingContentBox.detachChildren();
    // Remove scrolling content box.
    outerLayoutBox.remove(scrollingContentBox);

    (this as Element).style.removeStyleChangeListener(scrollingContentBoxStyleListener);
    // Move children of scrolling content box to the children to outer layout box.
    outerLayoutBox.addAll(children);
  }

  double get scrollTop {
    WebFScrollable? scrollableY = _getScrollable(Axis.vertical);
    if (scrollableY != null) {
      return scrollableY.position?.pixels ?? 0;
    }
    return 0.0;
  }

  set scrollTop(double value) {
    _scrollTo(y: value);
  }

  void scroll(double x, double y, [bool withAnimation = false]) {
    _scrollTo(x: x, y: y, withAnimation: withAnimation);
  }

  void scrollBy(double x, double y, [bool withAnimation = false]) {
    _scrollBy(dx: x, dy: y, withAnimation: withAnimation);
  }

  void scrollTo(double x, double y, [bool withAnimation = false]) {
    _scrollTo(x: x, y: y, withAnimation: withAnimation);
  }

  void _ensureRenderObjectHasLayout() {
    if (renderStyle.getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.needsLayout)?.needsLayout == true) {
      RendererBinding.instance.rootPipelineOwner.flushLayout();
    }
  }

  double get scrollLeft {
    WebFScrollable? scrollableX = _getScrollable(Axis.horizontal);
    if (scrollableX != null) {
      return scrollableX.position?.pixels ?? 0;
    }
    return 0.0;
  }

  set scrollLeft(double value) {
    _scrollTo(x: value);
  }

  double get scrollHeight {
    if (!isRendererAttached) {
      return 0.0;
    }
    _ensureRenderObjectHasLayout();
    WebFScrollable? scrollable = _getScrollable(Axis.vertical);
    if (scrollable?.position?.maxScrollExtent != null) {
      // Viewport height + maxScrollExtent
      return renderStyle.clientHeight()! + scrollable!.position!.maxScrollExtent;
    }

    Size scrollContainerSize = renderStyle.scrollableSize()!;
    return scrollContainerSize.height;
  }

  double get scrollWidth {
    if (!isRendererAttached) {
      return 0.0;
    }
    _ensureRenderObjectHasLayout();
    WebFScrollable? scrollable = _getScrollable(Axis.horizontal);
    if (scrollable?.position?.maxScrollExtent != null) {
      return renderStyle.clientWidth()! + scrollable!.position!.maxScrollExtent;
    }
    Size scrollContainerSize = renderStyle.scrollableSize()!;
    return scrollContainerSize.width;
  }

  String get dir {
    return 'ltr';
  }

  double get clientTop {
    _ensureRenderObjectHasLayout();
    return renderStyle.effectiveBorderTopWidth.computedValue ?? 0.0;
  }

  double get clientLeft {
    _ensureRenderObjectHasLayout();
    return renderStyle.effectiveBorderLeftWidth.computedValue ?? 0.0;
  }

  double get clientWidth {
    _ensureRenderObjectHasLayout();
    return renderStyle.clientWidth() ?? 0.0;
  }

  double get clientHeight {
    _ensureRenderObjectHasLayout();
    return renderStyle.clientHeight() ?? 0.0;
  }

  double get offsetWidth {
    _ensureRenderObjectHasLayout();
    if (!renderStyle.hasRenderBox()) return 0;
    return renderStyle.getSelfRenderBoxValue((renderBox, _) => renderBox.hasSize ? renderBox.size.width : 0.0);
  }

  double get offsetHeight {
    _ensureRenderObjectHasLayout();
    if (!renderStyle.hasRenderBox()) return 0;
    return renderStyle.getSelfRenderBoxValue((renderBox, _) => renderBox.hasSize ? renderBox.size.height : 0.0);
  }

  void _scrollBy({double dx = 0.0, double dy = 0.0, bool? withAnimation}) {
    if (dx != 0) {
      _scroll(scrollLeft + dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(scrollTop + dy, Axis.vertical, withAnimation: withAnimation);
    }
  }

  void _scrollTo({double? x, double? y, bool? withAnimation}) {
    if (x != null) {
      _scroll(x, Axis.horizontal, withAnimation: withAnimation);
    }

    if (y != null) {
      _scroll(y, Axis.vertical, withAnimation: withAnimation);
    }
  }

  WebFScrollable? _getScrollable(Axis direction) {
    WebFScrollable? scrollable;
    if (renderer is RenderSliverListLayout) {
      RenderSliverListLayout recyclerLayout = renderer as RenderSliverListLayout;
      scrollable = direction == recyclerLayout.axis ? recyclerLayout.scrollable : null;
    } else {
      if (direction == Axis.horizontal) {
        scrollable = renderStyle._domScrollableX;
      } else if (direction == Axis.vertical) {
        scrollable = renderStyle._domScrollableY;
      }
    }
    return scrollable;
  }

  void _scroll(num aim, Axis direction, {bool? withAnimation = false}) {
    WebFScrollable? scrollable = _getScrollable(direction);
    if (scrollable != null) {
      double distance = aim.toDouble();

      // Apply scroll effect after layout.
      assert(isRendererAttached, 'Overflow can only be added to a RenderBox.');
      renderer!.owner!.flushLayout();

      scrollable.position!.moveTo(
        distance,
        duration: withAnimation == true ? SCROLL_DURATION : null,
        curve: withAnimation == true ? Curves.easeOut : null,
      );
    }
  }
}
