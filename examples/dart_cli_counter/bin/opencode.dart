import 'dart:async';

import 'package:opentui/opentui.dart';

Future<void> main() async {
  final adapter = TerminalAdapter();
  final queuedOutput = _QueuedOutputSink(adapter);
  final engine = TuiEngine(
    inputSource: adapter,
    outputSink: queuedOutput,
    viewportWidth: 120,
    viewportHeight: 32,
  );

  final files = <String>[
    'lib/main.dart',
    'lib/agent/planner.dart',
    'lib/ui/prompt_bar.dart',
    'docs/getting-started.md',
    'tool/release.dart',
  ];

  final workingTree = <String, String>{
    'lib/main.dart': '''
void main() {
  print("OpenCode shell ready");
}
''',
    'lib/agent/planner.dart': '''
class Planner {
  const Planner();

  String plan(String input) => "Plan: \$input";
}
''',
    'lib/ui/prompt_bar.dart': '''
class PromptBarState {
  final String prompt;
  final bool submitting;
  const PromptBarState(this.prompt, this.submitting);
}
''',
    'docs/getting-started.md': '''
# Getting Started

Run `/help` in the command bar.
''',
    'tool/release.dart': '''
Future<void> main(List<String> args) async {
  print("release check");
}
''',
  };
  final savedTree = <String, String>{
    for (final entry in workingTree.entries) entry.key: entry.value,
  };

  var activeFile = files.first;
  var logCounter = 0;
  final activityLines = <String>[
    '[boot] OpenCode-like demo initialized',
    '[hint] Tab to cycle focus, Ctrl+C to exit',
  ];

  final modeTabs = TuiTabSelect(
    id: 'mode-tabs',
    height: 1,
    options: const <String>['Chat', 'Code', 'Patch', 'Run'],
    selectedStyle: const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.green,
      bold: true,
    ),
  );

  final statusLine = TuiText(
    id: 'status',
    height: 1,
    text: '',
    style: const TuiStyle(foreground: TuiColor.cyan),
  );

  final workspaceSelect = TuiSelect(
    id: 'workspace-files',
    height: 9,
    options: List<String>.filled(files.length, ''),
    selectedStyle: const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.green,
      bold: true,
    ),
  );

  final activityText = TuiText(
    id: 'activity-log',
    height: 8,
    text: '',
    style: const TuiStyle(foreground: TuiColor.white),
  );

  final editorHeader = TuiText(
    id: 'editor-header',
    height: 1,
    text: '',
    style: const TuiStyle(foreground: TuiColor(255, 215, 0), bold: true),
  );

  final editor = TuiTextarea(
    id: 'editor',
    height: 11,
    value: workingTree[activeFile] ?? '',
    style: const TuiStyle(foreground: TuiColor.white),
    focusedStyle: const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.white,
    ),
  );

  final diffPreview = TuiText(
    id: 'diff-preview',
    height: 7,
    text: '',
    style: const TuiStyle(foreground: TuiColor(255, 120, 220)),
  );

  final actionSelect = TuiSelect(
    id: 'actions',
    height: 5,
    options: const <String>[
      'Run workspace checks',
      'Apply patch preview',
      'Save active file',
      'Open docs',
      'Rollback active file',
    ],
  );

  final temperatureSlider = TuiSlider(
    id: 'temperature',
    height: 1,
    value: 35,
    min: 0,
    max: 100,
    step: 5,
  );

  final inspectorText = TuiText(
    id: 'inspector',
    height: 5,
    text: '',
    style: const TuiStyle(foreground: TuiColor.cyan),
  );

  final commandInput = TuiInput(
    id: 'command-input',
    placeholder: '/help  /run  /save  /open <index|name>  /reset',
    style: const TuiStyle(foreground: TuiColor.white),
    focusedStyle: const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.white,
    ),
  );

  final commandHint = TuiText(
    id: 'command-help',
    height: 2,
    text:
        'Enter on Actions runs the selected workflow. Enter in command bar executes slash commands.\n'
        'Arrow keys edit/navigate. Tab cycles focus like terminal apps.',
    style: const TuiStyle(foreground: TuiColor.green),
  );

  void appendActivity(String message) {
    logCounter += 1;
    activityLines.add('[${logCounter.toString().padLeft(2, '0')}] $message');
    final start = activityLines.length > 8 ? activityLines.length - 8 : 0;
    activityText.text = activityLines.sublist(start).join('\n');
  }

  void refreshFileDecorations() {
    for (var i = 0; i < files.length; i++) {
      final path = files[i];
      final activeMarker = path == activeFile ? '>' : ' ';
      final dirtyMarker = workingTree[path] == savedTree[path] ? ' ' : '●';
      workspaceSelect.options[i] = '$activeMarker$dirtyMarker $path';
    }
  }

  void refreshInspector() {
    final mode = modeTabs.options[modeTabs.selectedIndex];
    final dirty = workingTree[activeFile] == savedTree[activeFile]
        ? 'clean'
        : 'dirty';
    final lineCount = '\n'.allMatches(editor.value).length + 1;
    inspectorText.text =
        'Model  : gpt-5-codex\n'
        'Mode   : $mode\n'
        'State  : $dirty\n'
        'Lines  : $lineCount\n'
        'Temp   : ${(temperatureSlider.value / 100).toStringAsFixed(2)}';
  }

  void refreshDiffPreview() {
    final previous = savedTree[activeFile] ?? '';
    final next = workingTree[activeFile] ?? '';
    diffPreview.text = _buildDiffPreview(previous: previous, next: next);
  }

  void refreshStatus() {
    final focused = engine.focusedNode?.id ?? 'none';
    final dirty = workingTree[activeFile] == savedTree[activeFile]
        ? 'clean'
        : 'dirty';
    statusLine.text =
        'model=gpt-5-codex  active=$activeFile  state=$dirty  focus=$focused';
    editorHeader.text =
        'Editing: $activeFile ${dirty == 'dirty' ? '(modified)' : '(saved)'}';
    refreshFileDecorations();
    refreshInspector();
    refreshDiffPreview();
  }

  void openFile(int index, {required String reason}) {
    if (index < 0 || index >= files.length) {
      return;
    }
    workspaceSelect.selectedIndex = index;
    activeFile = files[index];
    editor.value = workingTree[activeFile] ?? '';
    editor.cursorPosition = editor.value.length;
    appendActivity('open $activeFile ($reason)');
    refreshStatus();
  }

  void syncEditorToTree() {
    if (workingTree[activeFile] == editor.value) {
      return;
    }
    workingTree[activeFile] = editor.value;
    refreshStatus();
  }

  void saveActiveFile() {
    savedTree[activeFile] = workingTree[activeFile] ?? '';
    appendActivity('saved $activeFile');
    refreshStatus();
  }

  void rollbackActiveFile() {
    workingTree[activeFile] = savedTree[activeFile] ?? '';
    editor.value = workingTree[activeFile] ?? '';
    editor.cursorPosition = editor.value.length;
    appendActivity('rollback $activeFile');
    refreshStatus();
  }

  void runSelectedAction() {
    switch (actionSelect.selectedIndex) {
      case 0:
        appendActivity('check: analyzing workspace...');
        appendActivity('check: no critical diagnostics');
        break;
      case 1:
        appendActivity('patch: generated preview for $activeFile');
        break;
      case 2:
        saveActiveFile();
        break;
      case 3:
        appendActivity('docs: open docs/getting-started.md');
        break;
      case 4:
        rollbackActiveFile();
        break;
    }
    refreshStatus();
  }

  void executeCommand(String command) {
    if (command.isEmpty) {
      appendActivity('command ignored: empty');
      return;
    }
    if (command == '/help') {
      appendActivity('commands: /help /run /save /open <index|name> /reset');
      return;
    }
    if (command == '/run') {
      appendActivity('run: executing workspace checks');
      appendActivity('run: completed successfully');
      return;
    }
    if (command == '/save') {
      saveActiveFile();
      return;
    }
    if (command == '/reset') {
      rollbackActiveFile();
      return;
    }
    if (command.startsWith('/open ')) {
      final target = command.substring('/open '.length).trim();
      final index = int.tryParse(target);
      if (index != null && index >= 1 && index <= files.length) {
        openFile(index - 1, reason: 'command');
        return;
      }
      final matchIndex = files.indexWhere(
        (path) => path.toLowerCase().contains(target.toLowerCase()),
      );
      if (matchIndex >= 0) {
        openFile(matchIndex, reason: 'command');
        return;
      }
      appendActivity('open failed: "$target"');
      return;
    }
    appendActivity('unknown command: $command');
  }

  final leftPanel =
      TuiBox(
          id: 'left-panel',
          width: 30,
          border: true,
          title: 'Workspace',
          padding: 1,
          layoutDirection: TuiLayoutDirection.column,
        )
        ..add(
          TuiText(
            id: 'workspace-label',
            text: 'Files',
            style: const TuiStyle(foreground: TuiColor.green, bold: true),
          ),
        )
        ..add(workspaceSelect)
        ..add(
          TuiText(
            id: 'activity-label',
            text: 'Agent Feed',
            style: const TuiStyle(foreground: TuiColor.green, bold: true),
          ),
        )
        ..add(activityText);

  final centerPanel =
      TuiBox(
          id: 'center-panel',
          border: true,
          title: 'Editor',
          padding: 1,
          layoutDirection: TuiLayoutDirection.column,
          flexGrow: 2,
        )
        ..add(editorHeader)
        ..add(editor)
        ..add(
          TuiText(
            id: 'diff-label',
            text: 'Diff Preview',
            style: const TuiStyle(foreground: TuiColor.green, bold: true),
          ),
        )
        ..add(diffPreview);

  final rightPanel =
      TuiBox(
          id: 'right-panel',
          width: 34,
          border: true,
          title: 'Inspector',
          padding: 1,
          layoutDirection: TuiLayoutDirection.column,
        )
        ..add(
          TuiText(
            id: 'action-label',
            text: 'Actions',
            style: const TuiStyle(foreground: TuiColor.green, bold: true),
          ),
        )
        ..add(actionSelect)
        ..add(
          TuiText(
            id: 'temp-label',
            text: 'Creativity',
            style: const TuiStyle(foreground: TuiColor.green, bold: true),
          ),
        )
        ..add(temperatureSlider)
        ..add(inspectorText);

  final mainPanel =
      TuiBox(
          id: 'main-panel',
          layoutDirection: TuiLayoutDirection.row,
          flexGrow: 1,
          marginTop: 1,
        )
        ..add(leftPanel)
        ..add(centerPanel)
        ..add(rightPanel);

  final commandPanel =
      TuiBox(
          id: 'command-panel',
          border: true,
          title: 'Command Bar',
          padding: 1,
          layoutDirection: TuiLayoutDirection.column,
          height: 6,
          marginTop: 1,
        )
        ..add(commandInput)
        ..add(commandHint);

  final root =
      TuiBox(
          id: 'root',
          border: true,
          title: 'OpenCode Style CLI (opentui)',
          padding: 1,
          layoutDirection: TuiLayoutDirection.column,
          borderStyle: const TuiStyle(foreground: TuiColor.cyan),
        )
        ..add(modeTabs)
        ..add(statusLine)
        ..add(mainPanel)
        ..add(commandPanel);

  refreshStatus();
  openFile(0, reason: 'initial');
  engine.mount(root);
  await adapter.clear();
  engine.render();

  final done = Completer<void>();
  late final StreamSubscription<TuiKeyEvent> keySubscription;
  keySubscription = adapter.keyEvents.listen((event) {
    if (event.special == TuiSpecialKey.ctrlC) {
      if (!done.isCompleted) {
        done.complete();
      }
      return;
    }

    final focused = engine.focusedNode;
    final special = event.special;
    final isArrow =
        special == TuiSpecialKey.arrowUp ||
        special == TuiSpecialKey.arrowDown ||
        special == TuiSpecialKey.arrowLeft ||
        special == TuiSpecialKey.arrowRight;

    if (focused == workspaceSelect &&
        (isArrow || special == TuiSpecialKey.enter)) {
      openFile(
        workspaceSelect.selectedIndex,
        reason: special == TuiSpecialKey.enter ? 'enter' : 'navigate',
      );
    }

    if (focused == modeTabs && isArrow) {
      appendActivity('mode -> ${modeTabs.options[modeTabs.selectedIndex]}');
    }

    if (focused == editor) {
      syncEditorToTree();
    }

    if (focused == actionSelect && special == TuiSpecialKey.enter) {
      runSelectedAction();
    }

    if (focused == commandInput && special == TuiSpecialKey.enter) {
      final command = commandInput.value.trim();
      executeCommand(command);
      commandInput.value = '';
      commandInput.cursorPosition = 0;
    }

    if (focused == temperatureSlider && isArrow) {
      appendActivity(
        'temperature -> ${(temperatureSlider.value / 100).toStringAsFixed(2)}',
      );
    }

    refreshStatus();
    engine.render();
  });

  await done.future;
  await keySubscription.cancel();
  await engine.dispose();
  await adapter.dispose();
}

String _buildDiffPreview({
  required String previous,
  required String next,
  int maxLines = 6,
}) {
  final oldLines = previous.split('\n');
  final newLines = next.split('\n');
  final maxCount = oldLines.length > newLines.length
      ? oldLines.length
      : newLines.length;

  final lines = <String>[];
  for (var i = 0; i < maxCount; i++) {
    final oldLine = i < oldLines.length ? oldLines[i] : null;
    final newLine = i < newLines.length ? newLines[i] : null;
    if (oldLine == newLine && newLine != null) {
      lines.add('  $newLine');
      continue;
    }
    if (oldLine != null) {
      lines.add('- $oldLine');
    }
    if (newLine != null) {
      lines.add('+ $newLine');
    }
  }

  if (lines.isEmpty) {
    return 'No changes';
  }
  if (lines.length <= maxLines) {
    return lines.join('\n');
  }
  final clipped = lines.sublist(0, maxLines - 1);
  clipped.add('... (${lines.length - (maxLines - 1)} more)');
  return clipped.join('\n');
}

final class _QueuedOutputSink implements TuiOutputSink {
  _QueuedOutputSink(this._delegate);

  final TuiOutputSink _delegate;
  Future<void> _pending = Future<void>.value();

  @override
  Future<void> present(TuiFrame frame) {
    final snapshot = frame.clone();
    _pending = _pending.then((_) async {
      final result = _delegate.present(snapshot);
      if (result is Future<void>) {
        await result;
      }
    });
    return _pending;
  }
}
