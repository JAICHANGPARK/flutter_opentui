# OpenTuiController & Input

`OpenTuiController`는 Flutter <-> OpenTUI 엔진 사이의 이벤트 허브입니다.

## 핵심 API

- `attachEngine(engine)`
- `detach(disposeEngine: true|false)`
- `sendKeyEvent(event)`
- `sendCharacter(...)`
- `sendSpecialKey(...)`
- `sendPaste(...)`
- `sendResize(width: ..., height: ...)`

## FlutterInputSource

`FlutterInputSource`는 다음 스트림을 제공합니다.

- `keyEvents`
- `resizeEvents`
- `keyDispatches` (메타데이터 포함)
- `pasteEvents`

## 예제

```dart
controller.sendSpecialKey(TuiSpecialKey.arrowDown, shift: true);
controller.sendCharacter('k', ctrl: true);
controller.sendPaste('multi\nline\ntext');
```
