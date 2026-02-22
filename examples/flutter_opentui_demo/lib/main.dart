import 'package:flutter/material.dart';
import 'package:flutter_opentui/flutter_opentui.dart' hide Text;

void main() {
  runApp(const OpenTuiDemoApp());
}

class OpenTuiDemoApp extends StatelessWidget {
  const OpenTuiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OpenTuiDemoScreen(),
    );
  }
}

class OpenTuiDemoScreen extends StatefulWidget {
  const OpenTuiDemoScreen({super.key});

  @override
  State<OpenTuiDemoScreen> createState() => _OpenTuiDemoScreenState();
}

class _OpenTuiDemoScreenState extends State<OpenTuiDemoScreen> {
  static const List<String> _componentNames = <String>[
    'TuiBox',
    'TuiText',
    'TuiInput',
    'TuiTextarea',
    'TuiSelect',
    'TuiTabSelect',
    'TuiAsciiFont',
    'TuiFrameBufferNode',
    'TuiMarkdown',
    'TuiCode',
    'TuiDiff',
    'TuiLineNumber',
    'TuiScrollBox',
    'TuiScrollbar',
    'TuiSlider',
  ];

  final OpenTuiController _controller = OpenTuiController();

  final OptimizedBuffer _statusBuffer = OptimizedBuffer(width: 36, height: 3)
    ..drawText(
      0,
      0,
      'frameBuffer: mounted',
      style: const TuiStyle(foreground: TuiColor.green),
    )
    ..drawText(
      0,
      1,
      'engine: flutter_opentui',
      style: const TuiStyle(foreground: TuiColor.cyan),
    )
    ..drawText(0, 2, 'catalog: all components');

  late TuiText _catalogStatus;
  late TuiSelect _componentIndex;
  late TuiScrollBox _componentGallery;
  late TuiNode _root;

  int _lastSelectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _buildCatalogTree();
    _controller.addListener(_handleControllerTick);
    _syncCatalogSelection(force: true);
  }

  void _buildCatalogTree() {
    _catalogStatus = TuiText(
      id: 'catalog-status',
      height: 1,
      text: '',
      style: const TuiStyle(foreground: TuiColor.cyan),
    );

    _componentIndex = TuiSelect(
      id: 'component-index',
      height: _componentNames.length,
      options: List<String>.from(_componentNames),
      selectedStyle: const TuiStyle(
        foreground: TuiColor.black,
        background: TuiColor.green,
        bold: true,
      ),
    );

    _componentGallery =
        TuiScrollBox(
            id: 'component-gallery',
            border: false,
            padding: 0,
            layoutDirection: TuiLayoutDirection.column,
            scrollStep: 1,
            fastScrollStep: 3,
          )
          ..add(_buildBoxCard())
          ..add(_buildTextCard())
          ..add(_buildInputCard())
          ..add(_buildTextareaCard())
          ..add(_buildSelectCard())
          ..add(_buildTabSelectCard())
          ..add(_buildAsciiFontCard())
          ..add(_buildFrameBufferCard())
          ..add(_buildMarkdownCard())
          ..add(_buildCodeCard())
          ..add(_buildDiffCard())
          ..add(_buildLineNumberCard())
          ..add(_buildScrollBoxCard())
          ..add(_buildScrollbarCard())
          ..add(_buildSliderCard());

    _root =
        TuiBox(
            id: 'root',
            border: true,
            title: 'flutter_opentui Component Catalog',
            layoutDirection: TuiLayoutDirection.column,
            padding: 1,
          )
          ..add(
            TuiAsciiFont(
              id: 'catalog-logo',
              text: 'OpenTUI',
              height: 5,
              style: const TuiStyle(foreground: TuiColor.cyan),
            ),
          )
          ..add(_catalogStatus)
          ..add(
            TuiText(
              id: 'catalog-help',
              text:
                  'Tab to focus index/gallery, arrows to navigate. The preview jumps to the selected component.',
              style: const TuiStyle(foreground: TuiColor.green),
            ),
          )
          ..add(
            TuiBox(
                id: 'catalog-body',
                layoutDirection: TuiLayoutDirection.row,
                flexGrow: 1,
                marginTop: 1,
              )
              ..add(
                TuiBox(
                    id: 'catalog-index-panel',
                    width: 34,
                    border: true,
                    title: 'Component Index',
                    padding: 1,
                    layoutDirection: TuiLayoutDirection.column,
                  )
                  ..add(_componentIndex)
                  ..add(
                    TuiText(
                      id: 'catalog-index-help',
                      height: 2,
                      text:
                          'Pick a component with arrows.\nPreview panel follows.',
                      style: const TuiStyle(foreground: TuiColor.cyan),
                    ),
                  ),
              )
              ..add(
                TuiBox(
                  id: 'catalog-preview-panel',
                  border: true,
                  title: 'Component Preview',
                  layoutDirection: TuiLayoutDirection.column,
                  padding: 1,
                  marginLeft: 1,
                  flexGrow: 1,
                )..add(_componentGallery),
              ),
          );
  }

  TuiBox _componentCard({
    required String id,
    required String title,
    required int height,
    required List<TuiNode> children,
  }) {
    final card = TuiBox(
      id: id,
      border: true,
      title: title,
      height: height,
      padding: 1,
      marginBottom: 1,
      layoutDirection: TuiLayoutDirection.column,
    );
    for (final child in children) {
      card.add(child);
    }
    return card;
  }

  TuiNode _buildBoxCard() {
    return _componentCard(
      id: 'card-box',
      title: 'TuiBox',
      height: 8,
      children: <TuiNode>[
        TuiText(
          id: 'card-box-desc',
          text: 'Container component with border, padding, and nested layout.',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
        TuiBox(
          id: 'card-box-inner',
          border: true,
          title: 'Nested Box',
          height: 3,
          padding: 1,
          borderStyle: const TuiStyle(foreground: TuiColor.green),
        )..add(
          TuiText(
            id: 'card-box-inner-text',
            text: 'Box inside Box',
            style: const TuiStyle(foreground: TuiColor.white),
          ),
        ),
      ],
    );
  }

  TuiNode _buildTextCard() {
    return _componentCard(
      id: 'card-text',
      title: 'TuiText',
      height: 6,
      children: <TuiNode>[
        TuiText(
          id: 'card-text-node',
          text: 'Plain text rendering.\nSupports multi-line content and style.',
          style: const TuiStyle(foreground: TuiColor.white),
        ),
      ],
    );
  }

  TuiNode _buildInputCard() {
    return _componentCard(
      id: 'card-input',
      title: 'TuiInput',
      height: 6,
      children: <TuiNode>[
        TuiText(
          id: 'card-input-desc',
          text: 'Single-line editable field.',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
        TuiInput(id: 'card-input-node', placeholder: 'Type in TuiInput...'),
      ],
    );
  }

  TuiNode _buildTextareaCard() {
    return _componentCard(
      id: 'card-textarea',
      title: 'TuiTextarea',
      height: 8,
      children: <TuiNode>[
        TuiText(
          id: 'card-textarea-desc',
          text: 'Multi-line editor with vertical cursor movement.',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
        TuiTextarea(
          id: 'card-textarea-node',
          height: 3,
          value: 'line one\nline two\nline three',
        ),
      ],
    );
  }

  TuiNode _buildSelectCard() {
    return _componentCard(
      id: 'card-select',
      title: 'TuiSelect',
      height: 8,
      children: <TuiNode>[
        TuiText(
          id: 'card-select-desc',
          text: 'Arrow-driven vertical list selection.',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
        TuiSelect(
          id: 'card-select-node',
          height: 3,
          options: const <String>['Option A', 'Option B', 'Option C'],
        ),
      ],
    );
  }

  TuiNode _buildTabSelectCard() {
    return _componentCard(
      id: 'card-tab-select',
      title: 'TuiTabSelect',
      height: 6,
      children: <TuiNode>[
        TuiTabSelect(
          id: 'card-tab-select-node',
          options: const <String>['Overview', 'Logs', 'Metrics'],
        ),
      ],
    );
  }

  TuiNode _buildAsciiFontCard() {
    return _componentCard(
      id: 'card-ascii-font',
      title: 'TuiAsciiFont',
      height: 8,
      children: <TuiNode>[
        TuiAsciiFont(
          id: 'card-ascii-font-node',
          text: 'TUI',
          height: 5,
          style: const TuiStyle(foreground: TuiColor.cyan),
        ),
      ],
    );
  }

  TuiNode _buildFrameBufferCard() {
    return _componentCard(
      id: 'card-frame-buffer',
      title: 'TuiFrameBufferNode',
      height: 7,
      children: <TuiNode>[
        TuiFrameBufferNode(
          id: 'card-frame-buffer-node',
          height: 3,
          buffer: _statusBuffer,
          transparent: true,
        ),
      ],
    );
  }

  TuiNode _buildMarkdownCard() {
    return _componentCard(
      id: 'card-markdown',
      title: 'TuiMarkdown',
      height: 7,
      children: <TuiNode>[
        TuiMarkdown(
          id: 'card-markdown-node',
          height: 3,
          markdown: '# Markdown\n- bullet one\n- bullet two',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
      ],
    );
  }

  TuiNode _buildCodeCard() {
    return _componentCard(
      id: 'card-code',
      title: 'TuiCode',
      height: 7,
      children: <TuiNode>[
        TuiCode(
          id: 'card-code-node',
          height: 3,
          code: 'final count = 42;\nprint(count);',
          style: const TuiStyle(foreground: TuiColor.cyan),
        ),
      ],
    );
  }

  TuiNode _buildDiffCard() {
    return _componentCard(
      id: 'card-diff',
      title: 'TuiDiff',
      height: 8,
      children: <TuiNode>[
        TuiDiff(
          id: 'card-diff-node',
          height: 4,
          previous: 'port=3000\nmode=dev',
          next: 'port=8080\nmode=prod',
        ),
      ],
    );
  }

  TuiNode _buildLineNumberCard() {
    return _componentCard(
      id: 'card-line-number',
      title: 'TuiLineNumber',
      height: 8,
      children: <TuiNode>[
        TuiLineNumber(
          id: 'card-line-number-node',
          height: 4,
          lines: const <String>['alpha()', 'beta()', 'gamma()'],
        ),
      ],
    );
  }

  TuiNode _buildScrollBoxCard() {
    return _componentCard(
      id: 'card-scrollbox',
      title: 'TuiScrollBox',
      height: 9,
      children: <TuiNode>[
        TuiScrollBox(
            id: 'card-scrollbox-node',
            border: true,
            title: 'Nested Scroll',
            height: 4,
            scrollStep: 1,
            fastScrollStep: 2,
          )
          ..add(TuiText(id: 'card-scrollbox-line-1', text: 'line 01'))
          ..add(TuiText(id: 'card-scrollbox-line-2', text: 'line 02'))
          ..add(TuiText(id: 'card-scrollbox-line-3', text: 'line 03'))
          ..add(TuiText(id: 'card-scrollbox-line-4', text: 'line 04'))
          ..add(TuiText(id: 'card-scrollbox-line-5', text: 'line 05')),
      ],
    );
  }

  TuiNode _buildScrollbarCard() {
    return _componentCard(
      id: 'card-scrollbar',
      title: 'TuiScrollbar',
      height: 8,
      children: <TuiNode>[
        TuiText(
          id: 'card-scrollbar-desc',
          text: 'Interactive vertical scrollbar.',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
        TuiScrollbar(
          id: 'card-scrollbar-node',
          height: 4,
          width: 1,
          value: 0.45,
          thumbRatio: 0.35,
        ),
      ],
    );
  }

  TuiNode _buildSliderCard() {
    return _componentCard(
      id: 'card-slider',
      title: 'TuiSlider',
      height: 7,
      children: <TuiNode>[
        TuiText(
          id: 'card-slider-desc',
          text: 'Horizontal slider (0-100).',
          style: const TuiStyle(foreground: TuiColor.green),
        ),
        TuiSlider(
          id: 'card-slider-node',
          width: 28,
          value: 55,
          min: 0,
          max: 100,
          step: 5,
        ),
      ],
    );
  }

  void _handleControllerTick() {
    _syncCatalogSelection();
  }

  void _syncCatalogSelection({bool force = false}) {
    if (_componentNames.isEmpty) {
      return;
    }

    final maxIndex = _componentNames.length - 1;
    var shouldRender = false;

    final focusedNode = _controller.engine?.focusedNode;
    final galleryOffset = _componentGallery.scrollOffset.clamp(0, maxIndex);
    if (focusedNode == _componentGallery &&
        galleryOffset != _componentIndex.selectedIndex) {
      _componentIndex.selectedIndex = galleryOffset;
      shouldRender = true;
    }

    final selected = _componentIndex.selectedIndex.clamp(0, maxIndex);
    if (_componentGallery.scrollOffset != selected) {
      _componentGallery.scrollOffset = selected;
      shouldRender = true;
    }

    if (force || selected != _lastSelectedIndex) {
      _lastSelectedIndex = selected;
      _catalogStatus.text =
          'Coverage: ${_componentNames.length}/${_componentNames.length} components · '
          'Selected: ${_componentNames[selected]}';
      shouldRender = true;
    }

    if (shouldRender) {
      _controller.engine?.render();
    }
  }

  void _jumpComponent(int delta) {
    if (_componentNames.isEmpty) {
      return;
    }

    final maxIndex = _componentNames.length - 1;
    final next = (_componentIndex.selectedIndex + delta).clamp(0, maxIndex);
    if (next == _componentIndex.selectedIndex) {
      return;
    }
    _componentIndex.selectedIndex = next;
    _syncCatalogSelection(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: OpenTuiView(controller: _controller, root: _root),
            ),
            Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _QuickInput(label: 'Prev', onTap: () => _jumpComponent(-1)),
                  _QuickInput(label: 'Next', onTap: () => _jumpComponent(1)),
                  _QuickInput(
                    label: 'Tab',
                    onTap: () => _controller.sendSpecialKey(TuiSpecialKey.tab),
                  ),
                  _QuickInput(
                    label: 'Up',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowUp),
                  ),
                  _QuickInput(
                    label: 'Down',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowDown),
                  ),
                  _QuickInput(
                    label: 'Left',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowLeft),
                  ),
                  _QuickInput(
                    label: 'Right',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowRight),
                  ),
                  _QuickInput(
                    label: 'Paste',
                    onTap: () => _controller.sendPaste('deploy --dry-run'),
                  ),
                  _QuickInput(
                    label: 'A',
                    onTap: () => _controller.sendCharacter('a'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerTick);
    _controller.dispose();
    super.dispose();
  }
}

class _QuickInput extends StatelessWidget {
  const _QuickInput({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      child: Text(label),
    );
  }
}
