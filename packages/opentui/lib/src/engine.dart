import 'dart:async';

import 'events.dart';
import 'frame.dart';
import 'node.dart';

final class TuiEngine {
  TuiEngine({
    required this.inputSource,
    required this.outputSink,
    this.viewportWidth = 80,
    this.viewportHeight = 24,
  }) {
    _keySubscription = inputSource.keyEvents.listen(_handleKeyEvent);
    _resizeSubscription = inputSource.resizeEvents.listen(_handleResizeEvent);
  }

  final TuiInputSource inputSource;
  final TuiOutputSink outputSink;

  int viewportWidth;
  int viewportHeight;

  TuiNode? _root;
  TuiNode? _focusedNode;
  TuiFrame? _lastFrame;

  late final StreamSubscription<TuiKeyEvent> _keySubscription;
  late final StreamSubscription<TuiResizeEvent> _resizeSubscription;

  final StreamController<TuiFrame> _framesController =
      StreamController<TuiFrame>.broadcast();

  bool _isDisposed = false;

  Stream<TuiFrame> get frames => _framesController.stream;

  TuiNode? get root => _root;

  TuiNode? get focusedNode => _focusedNode;

  TuiFrame? get lastFrame => _lastFrame;

  void mount(TuiNode rootNode) {
    _assertNotDisposed();
    _root = rootNode;
    _rebuildFocusTree();
  }

  void render() {
    _assertNotDisposed();
    final rootNode = _root;
    if (rootNode == null || viewportWidth <= 0 || viewportHeight <= 0) {
      return;
    }

    _layoutNode(
      rootNode,
      TuiRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight),
    );

    final frame = TuiFrame.blank(width: viewportWidth, height: viewportHeight);
    _paintNode(rootNode, frame);

    _lastFrame = frame.clone();
    final presentResult = outputSink.present(frame);
    if (presentResult is Future) {
      unawaited(presentResult);
    }
    _framesController.add(frame);
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    await _keySubscription.cancel();
    await _resizeSubscription.cancel();
    await _framesController.close();
  }

  void _handleKeyEvent(TuiKeyEvent event) {
    if (_isDisposed) {
      return;
    }

    if (event.special == TuiSpecialKey.tab) {
      _cycleFocus(forward: !event.shift);
      render();
      return;
    }

    final focused = _focusedNode;
    if (focused != null) {
      focused.onKey(event);
      render();
    }
  }

  void _handleResizeEvent(TuiResizeEvent event) {
    if (_isDisposed) {
      return;
    }
    viewportWidth = event.width;
    viewportHeight = event.height;
    render();
  }

  void _rebuildFocusTree() {
    final rootNode = _root;
    if (rootNode == null) {
      _focusedNode = null;
      return;
    }

    final focusables = <TuiNode>[];
    _collectFocusables(rootNode, focusables);
    if (focusables.isEmpty) {
      _focusedNode = null;
      return;
    }

    for (final node in focusables) {
      node.focused = false;
    }

    _focusedNode = focusables.first;
    _focusedNode!.focused = true;
  }

  void _collectFocusables(TuiNode node, List<TuiNode> output) {
    if (node.focusable) {
      output.add(node);
    }
    for (final child in node.children) {
      _collectFocusables(child, output);
    }
  }

  void _cycleFocus({required bool forward}) {
    final rootNode = _root;
    if (rootNode == null) {
      return;
    }

    final focusables = <TuiNode>[];
    _collectFocusables(rootNode, focusables);
    if (focusables.isEmpty) {
      _focusedNode = null;
      return;
    }

    final previous = _focusedNode;
    final currentIndex = previous == null ? -1 : focusables.indexOf(previous);
    final nextIndex = currentIndex < 0
        ? 0
        : forward
        ? (currentIndex + 1) % focusables.length
        : (currentIndex - 1 + focusables.length) % focusables.length;

    if (previous != null) {
      previous.focused = false;
    }
    _focusedNode = focusables[nextIndex];
    _focusedNode!.focused = true;
  }

  void _layoutNode(TuiNode node, TuiRect bounds) {
    node.setLayoutBounds(bounds);
    if (node.children.isEmpty) {
      return;
    }

    final contentBounds = _contentBounds(node, bounds);
    if (contentBounds.width <= 0 || contentBounds.height <= 0) {
      for (final child in node.children) {
        child.setLayoutBounds(
          TuiRect(x: contentBounds.x, y: contentBounds.y, width: 0, height: 0),
        );
      }
      return;
    }

    final layoutDirection = node is TuiBox
        ? node.layoutDirection
        : TuiLayoutDirection.column;

    switch (layoutDirection) {
      case TuiLayoutDirection.absolute:
        _layoutAbsolute(node.children, contentBounds);
      case TuiLayoutDirection.row:
        _layoutRow(node.children, contentBounds);
      case TuiLayoutDirection.column:
        _layoutColumn(node.children, contentBounds);
    }
  }

  TuiRect _contentBounds(TuiNode node, TuiRect bounds) {
    if (node is! TuiBox) {
      return bounds;
    }

    final borderInset = node.border ? 1 : 0;
    final padding = node.padding;
    final inset = borderInset + padding;

    final x = bounds.x + inset;
    final y = bounds.y + inset;
    final width = bounds.width - (inset * 2);
    final height = bounds.height - (inset * 2);

    return TuiRect(
      x: x,
      y: y,
      width: width < 0 ? 0 : width,
      height: height < 0 ? 0 : height,
    );
  }

  void _layoutAbsolute(List<TuiNode> children, TuiRect bounds) {
    for (final child in children) {
      final childX = bounds.x + (child.left ?? 0);
      final childY = bounds.y + (child.top ?? 0);
      final childWidth = child.width ?? bounds.width;
      final childHeight = child.height ?? _defaultNodeHeight(child);
      final clamped = _clampRect(
        parent: bounds,
        x: childX,
        y: childY,
        width: childWidth,
        height: childHeight,
      );
      _layoutNode(child, clamped);
    }
  }

  void _layoutRow(List<TuiNode> children, TuiRect bounds) {
    if (children.isEmpty) {
      return;
    }

    final fixedWidth = children
        .where((node) => node.width != null)
        .fold<int>(0, (sum, node) => sum + node.width!);
    final freeWidth = (bounds.width - fixedWidth)
        .clamp(0, bounds.width)
        .toInt();
    final flexIndices = <int>[];
    var totalFlexGrow = 0.0;
    for (var i = 0; i < children.length; i++) {
      if (children[i].width == null) {
        flexIndices.add(i);
        totalFlexGrow += children[i].flexGrow <= 0 ? 0 : children[i].flexGrow;
      }
    }

    final assignedWidths = List<int>.filled(
      children.length,
      0,
      growable: false,
    );
    if (flexIndices.isNotEmpty) {
      final resolvedFlexGrow = totalFlexGrow <= 0
          ? List<double>.filled(flexIndices.length, 1.0, growable: false)
          : flexIndices
                .map((index) {
                  final grow = children[index].flexGrow;
                  return grow <= 0 ? 0.0 : grow;
                })
                .toList(growable: false);
      final flexGrowTotal = totalFlexGrow <= 0
          ? flexIndices.length.toDouble()
          : totalFlexGrow;

      var flexAssigned = 0;
      for (var i = 0; i < flexIndices.length; i++) {
        final childIndex = flexIndices[i];
        final remaining = freeWidth - flexAssigned;
        final width = i == flexIndices.length - 1
            ? remaining
            : ((freeWidth * resolvedFlexGrow[i]) / flexGrowTotal)
                  .floor()
                  .clamp(0, remaining)
                  .toInt();
        assignedWidths[childIndex] = width;
        flexAssigned += width;
      }
    }

    var cursorX = bounds.x;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final width = child.width ?? assignedWidths[i];
      final childY = bounds.y + (child.top ?? 0);
      final childHeight = child.height ?? (bounds.height - (child.top ?? 0));
      final clamped = _clampRect(
        parent: bounds,
        x: cursorX,
        y: childY,
        width: width,
        height: childHeight,
      );
      _layoutNode(child, clamped);
      cursorX += width;
    }
  }

  void _layoutColumn(List<TuiNode> children, TuiRect bounds) {
    if (children.isEmpty) {
      return;
    }

    final fixedHeight = children
        .where((node) => node.height != null)
        .fold<int>(0, (sum, node) => sum + node.height!);
    final freeHeight = (bounds.height - fixedHeight)
        .clamp(0, bounds.height)
        .toInt();
    final flexIndices = <int>[];
    var totalFlexGrow = 0.0;
    for (var i = 0; i < children.length; i++) {
      if (children[i].height == null) {
        flexIndices.add(i);
        totalFlexGrow += children[i].flexGrow <= 0 ? 0 : children[i].flexGrow;
      }
    }

    final assignedHeights = List<int>.filled(
      children.length,
      0,
      growable: false,
    );
    if (flexIndices.isNotEmpty) {
      final resolvedFlexGrow = totalFlexGrow <= 0
          ? List<double>.filled(flexIndices.length, 1.0, growable: false)
          : flexIndices
                .map((index) {
                  final grow = children[index].flexGrow;
                  return grow <= 0 ? 0.0 : grow;
                })
                .toList(growable: false);
      final flexGrowTotal = totalFlexGrow <= 0
          ? flexIndices.length.toDouble()
          : totalFlexGrow;

      var flexAssigned = 0;
      for (var i = 0; i < flexIndices.length; i++) {
        final childIndex = flexIndices[i];
        final remaining = freeHeight - flexAssigned;
        final height = i == flexIndices.length - 1
            ? remaining
            : ((freeHeight * resolvedFlexGrow[i]) / flexGrowTotal)
                  .floor()
                  .clamp(0, remaining)
                  .toInt();
        assignedHeights[childIndex] = height;
        flexAssigned += height;
      }
    }

    var cursorY = bounds.y;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final height = child.height ?? assignedHeights[i];
      final childX = bounds.x + (child.left ?? 0);
      final childWidth = child.width ?? (bounds.width - (child.left ?? 0));
      final clamped = _clampRect(
        parent: bounds,
        x: childX,
        y: cursorY,
        width: childWidth,
        height: height,
      );
      _layoutNode(child, clamped);
      cursorY += height;
    }
  }

  int _defaultNodeHeight(TuiNode node) {
    if (node is TuiSelect) {
      return node.options.length;
    }
    if (node is TuiTabSelect) {
      return 1;
    }
    if (node is TuiAsciiFont) {
      return TuiAsciiFont.defaultGlyphHeight;
    }
    if (node is TuiFrameBufferNode) {
      return node.buffer.height;
    }
    return 1;
  }

  TuiRect _clampRect({
    required TuiRect parent,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    final startX = x.clamp(parent.x, parent.x + parent.width).toInt();
    final startY = y.clamp(parent.y, parent.y + parent.height).toInt();
    final endX = (x + width).clamp(parent.x, parent.x + parent.width).toInt();
    final endY = (y + height).clamp(parent.y, parent.y + parent.height).toInt();

    return TuiRect(
      x: startX,
      y: startY,
      width: endX - startX,
      height: endY - startY,
    );
  }

  void _paintNode(TuiNode node, TuiFrame frame) {
    final bounds = node.layoutBounds;
    if (bounds == null || bounds.width <= 0 || bounds.height <= 0) {
      return;
    }

    switch (node) {
      case TuiBox box:
        _paintBox(box, bounds, frame);
      case TuiText text:
        _paintText(text, bounds, frame);
      case TuiInput input:
        _paintInput(input, bounds, frame);
      case TuiSelect select:
        _paintSelect(select, bounds, frame);
      case TuiTabSelect tabSelect:
        _paintTabSelect(tabSelect, bounds, frame);
      case TuiAsciiFont asciiFont:
        _paintAsciiFont(asciiFont, bounds, frame);
      case TuiFrameBufferNode frameBuffer:
        _paintFrameBuffer(frameBuffer, bounds, frame);
    }

    for (final child in node.children) {
      _paintNode(child, frame);
    }
  }

  void _paintBox(TuiBox box, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      bounds.height,
      fill: TuiCell(char: ' ', style: box.style),
    );

    if (!box.border || bounds.width < 2 || bounds.height < 2) {
      return;
    }

    final left = bounds.x;
    final right = bounds.x + bounds.width - 1;
    final top = bounds.y;
    final bottom = bounds.y + bounds.height - 1;

    for (var x = left + 1; x < right; x++) {
      frame.setCell(x, top, TuiCell(char: '-', style: box.borderStyle));
      frame.setCell(x, bottom, TuiCell(char: '-', style: box.borderStyle));
    }
    for (var y = top + 1; y < bottom; y++) {
      frame.setCell(left, y, TuiCell(char: '|', style: box.borderStyle));
      frame.setCell(right, y, TuiCell(char: '|', style: box.borderStyle));
    }

    frame.setCell(left, top, TuiCell(char: '+', style: box.borderStyle));
    frame.setCell(right, top, TuiCell(char: '+', style: box.borderStyle));
    frame.setCell(left, bottom, TuiCell(char: '+', style: box.borderStyle));
    frame.setCell(right, bottom, TuiCell(char: '+', style: box.borderStyle));

    final title = box.title;
    if (title != null && title.isNotEmpty && bounds.width > 4) {
      frame.drawText(
        left + 2,
        top,
        title,
        style: box.borderStyle,
        maxWidth: bounds.width - 4,
      );
    }
  }

  void _paintText(TuiText text, TuiRect bounds, TuiFrame frame) {
    final lines = text.text.split('\n');
    for (var i = 0; i < lines.length && i < bounds.height; i++) {
      frame.drawText(
        bounds.x,
        bounds.y + i,
        lines[i],
        style: text.style,
        maxWidth: bounds.width,
      );
    }
  }

  void _paintInput(TuiInput input, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      1,
      fill: TuiCell(char: ' ', style: input.style),
    );

    final hasValue = input.value.isNotEmpty;
    final content = hasValue ? input.value : input.placeholder;
    final baseStyle = hasValue
        ? (input.focused ? input.focusedStyle : input.style)
        : input.placeholderStyle;

    frame.drawText(
      bounds.x,
      bounds.y,
      content,
      style: baseStyle,
      maxWidth: bounds.width,
    );

    if (!input.focused || bounds.width <= 0) {
      return;
    }

    final cursorOffset = input.cursorPosition
        .clamp(0, bounds.width - 1)
        .toInt();
    final cursorX = bounds.x + cursorOffset;
    final currentChar = cursorOffset < content.length
        ? content[cursorOffset]
        : ' ';

    frame.setCell(
      cursorX,
      bounds.y,
      TuiCell(
        char: currentChar,
        style: baseStyle.copyWith(inverse: !baseStyle.inverse),
      ),
    );
  }

  void _paintSelect(TuiSelect select, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      bounds.height,
      fill: TuiCell(char: ' ', style: select.style),
    );

    final visibleRows = bounds.height.clamp(0, select.options.length).toInt();
    for (var i = 0; i < visibleRows; i++) {
      final isSelected = i == select.selectedIndex;
      final marker = isSelected ? (select.focused ? '>' : '*') : ' ';
      final line = '$marker ${select.options[i]}';
      frame.drawText(
        bounds.x,
        bounds.y + i,
        line,
        style: isSelected ? select.selectedStyle : select.style,
        maxWidth: bounds.width,
      );
    }
  }

  void _paintTabSelect(TuiTabSelect tabSelect, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      1,
      fill: TuiCell(char: ' ', style: tabSelect.style),
    );

    var cursorX = bounds.x;
    final endX = bounds.x + bounds.width;
    for (var i = 0; i < tabSelect.options.length; i++) {
      if (cursorX >= endX) {
        break;
      }
      if (i > 0 && tabSelect.separator.isNotEmpty) {
        final separatorSpace = endX - cursorX;
        if (separatorSpace <= 0) {
          break;
        }
        frame.drawText(
          cursorX,
          bounds.y,
          tabSelect.separator,
          style: tabSelect.style,
          maxWidth: separatorSpace,
        );
        cursorX += tabSelect.separator.length;
      }

      if (cursorX >= endX) {
        break;
      }
      final label = ' ${tabSelect.options[i]} ';
      final style = i == tabSelect.selectedIndex
          ? tabSelect.selectedStyle
          : tabSelect.style;
      final labelSpace = endX - cursorX;
      if (labelSpace <= 0) {
        break;
      }
      frame.drawText(
        cursorX,
        bounds.y,
        label,
        style: style,
        maxWidth: labelSpace,
      );
      cursorX += label.length;
    }
  }

  void _paintAsciiFont(TuiAsciiFont asciiFont, TuiRect bounds, TuiFrame frame) {
    final lines = _asciiFontLines(asciiFont);
    final visibleRows = lines.length < bounds.height
        ? lines.length
        : bounds.height;

    for (var i = 0; i < visibleRows; i++) {
      frame.drawText(
        bounds.x,
        bounds.y + i,
        lines[i],
        style: asciiFont.style,
        maxWidth: bounds.width,
      );
    }
  }

  void _paintFrameBuffer(
    TuiFrameBufferNode frameBuffer,
    TuiRect bounds,
    TuiFrame frame,
  ) {
    final visibleWidth = bounds.width < frameBuffer.buffer.width
        ? bounds.width
        : frameBuffer.buffer.width;
    final visibleHeight = bounds.height < frameBuffer.buffer.height
        ? bounds.height
        : frameBuffer.buffer.height;

    for (var y = 0; y < visibleHeight; y++) {
      for (var x = 0; x < visibleWidth; x++) {
        final cell = frameBuffer.buffer.cellAt(x, y);
        if (frameBuffer.transparent && cell.char == ' ') {
          continue;
        }
        frame.setCell(bounds.x + x, bounds.y + y, cell);
      }
    }
  }

  List<String> _asciiFontLines(TuiAsciiFont asciiFont) {
    final runes = asciiFont.text.runes.toList(growable: false);
    final glyphHeight = TuiAsciiFont.defaultGlyphHeight;
    final lineBuffers = List<StringBuffer>.generate(
      glyphHeight,
      (_) => StringBuffer(),
      growable: false,
    );

    for (var index = 0; index < runes.length; index++) {
      final char = String.fromCharCode(runes[index]).toUpperCase();
      final glyph = _asciiGlyphs[char] ?? _fallbackGlyph(char);

      for (var row = 0; row < glyphHeight; row++) {
        if (index > 0 && asciiFont.letterSpacing > 0) {
          lineBuffers[row].write(''.padLeft(asciiFont.letterSpacing));
        }
        lineBuffers[row].write(glyph[row]);
      }
    }

    return lineBuffers.map((line) => line.toString()).toList(growable: false);
  }

  List<String> _fallbackGlyph(String char) {
    if (char.trim().isEmpty) {
      return const <String>['   ', '   ', '   ', '   ', '   '];
    }
    final rune = char.runes.isEmpty
        ? '?'
        : String.fromCharCode(char.runes.first);
    return <String>[
      ' $rune ',
      '$rune $rune',
      '$rune$rune$rune',
      '$rune $rune',
      '$rune $rune',
    ];
  }

  static const Map<String, List<String>> _asciiGlyphs = <String, List<String>>{
    'A': <String>[' /\\ ', '/__\\', '|  |', '|  |', '    '],
    'B': <String>['|~~\\', '|__/ ', '|~~\\', '|__/ ', '    '],
    'C': <String>[' /~~', '|   ', '|   ', ' \\__', '    '],
    'D': <String>['|~~\\', '|  |', '|  |', '|__/', '    '],
    'E': <String>['|~~~', '|__ ', '|   ', '|___', '    '],
    'F': <String>['|~~~', '|__ ', '|   ', '|   ', '    '],
    'G': <String>[' /~~', '| __', '|  |', ' \\_|', '    '],
    'H': <String>['|  |', '|__|', '|  |', '|  |', '    '],
    'I': <String>['-|-', ' | ', ' | ', '-|-', '   '],
    'J': <String>['  |', '  |', '| |', ' \\|', '   '],
    'K': <String>['| /', '|/ ', '|\\ ', '| \\', '   '],
    'L': <String>['|   ', '|   ', '|   ', '|___', '    '],
    'M': <String>['|\\/|', '|  |', '|  |', '|  |', '    '],
    'N': <String>['|\\ |', '| \\|', '|  |', '|  |', '    '],
    'O': <String>[' /\\ ', '|  |', '|  |', ' \\/ ', '    '],
    'P': <String>['|~~\\', '|__/', '|   ', '|   ', '    '],
    'Q': <String>[' /\\ ', '|  |', '| \\\\', ' \\/\\', '    '],
    'R': <String>['|~~\\', '|__/', '| \\ ', '|  \\', '    '],
    'S': <String>[' /~~', '(__ ', ' __)', '~~/ ', '    '],
    'T': <String>['~~~', ' | ', ' | ', ' | ', '   '],
    'U': <String>['|  |', '|  |', '|  |', ' \\/ ', '    '],
    'V': <String>['|  |', '|  |', ' \\/ ', '  V ', '    '],
    'W': <String>['|  |', '|  |', '|/\\|', '|  |', '    '],
    'X': <String>['\\ /', ' X ', '/ \\', '   ', '   '],
    'Y': <String>['\\ /', ' Y ', ' | ', ' | ', '   '],
    'Z': <String>['~~~/', '  / ', ' /  ', '/___', '    '],
    '0': <String>[' /\\ ', '/  \\', '|  |', ' \\_/ ', '    '],
    '1': <String>[' /|', '  |', '  |', '__|', '   '],
    '2': <String>['__/ ', '  / ', ' /  ', '/__ ', '    '],
    '3': <String>['__\\ ', ' _/ ', '  \\ ', '__/ ', '    '],
    '4': <String>['|  |', '|__|', '   |', '   |', '    '],
    '5': <String>['|__ ', '|__ ', '   |', '__/ ', '    '],
    '6': <String>[' /~ ', '|__ ', '|  |', ' \\_/ ', '    '],
    '7': <String>['___/', '  / ', ' /  ', '/   ', '    '],
    '8': <String>[' /\\ ', ' > <', '|  |', ' \\/ ', '    '],
    '9': <String>[' /\\ ', '|  |', ' \\_|', '  / ', '    '],
    ' ': <String>['   ', '   ', '   ', '   ', '   '],
  };

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('TuiEngine is disposed.');
    }
  }
}
