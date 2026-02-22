# OpenTuiView

`OpenTuiView`는 `TuiFrame`을 Flutter `CustomPaint`로 렌더링하는 위젯입니다.

## 기본 사용

```dart
OpenTuiView(
  controller: controller,
  root: root,
  cellWidth: 9,
  cellHeight: 18,
  autofocus: true,
)
```

## 주요 속성

- `controller`: `OpenTuiController`
- `root`: 렌더할 `TuiNode` 트리
- `cellWidth`, `cellHeight`: 문자 셀 크기
- `autofocus`: 키 입력 포커스 자동 획득 여부
- `backgroundColor`, `textStyle`: 화면 스타일

## 동작 요약

- 레이아웃 크기 -> 문자 셀 수 계산
- `sendResize(width, height)` 전달
- 키 이벤트를 `sendCharacter` / `sendSpecialKey` / `sendPaste`로 브리지
- 엔진 프레임 변경 시 자동 리페인트
