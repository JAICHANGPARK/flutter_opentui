# Layout

`opentui`는 `row`, `column`, `absolute` 레이아웃과 확장 레이아웃 속성을 지원합니다.

## 방향

- `TuiLayoutDirection.row`
- `TuiLayoutDirection.column`
- `TuiLayoutDirection.absolute`

## 정렬

- `justify`: `TuiJustify.start|center|end|spaceBetween|spaceAround|spaceEvenly`
- `align`: `TuiAlign.start|center|end|stretch`

## 크기

- 고정 크기: `width`, `height`
- 퍼센트: `widthPercent`, `heightPercent`
- 제약: `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
- 남는 공간 분배: `flexGrow`

## Wrap

`row/column`에서 줄바꿈 배치를 사용할 수 있습니다.

```dart
final root = Box(
  layoutDirection: TuiLayoutDirection.row,
  wrap: TuiWrap.wrap,
  children: <BaseRenderable>[
    Box(width: 20, height: 1),
    Box(width: 20, height: 1),
    Box(width: 20, height: 1),
  ],
);
```

## Margin

모든 노드에서 margin shorthand + per-edge를 지원합니다.

- `margin`
- `marginX`, `marginY`
- `marginLeft`, `marginTop`, `marginRight`, `marginBottom`

## Padding (Box)

`Box` 계열에서 padding shorthand + per-edge를 지원합니다.

- `padding`
- `paddingX`, `paddingY`
- `paddingLeft`, `paddingTop`, `paddingRight`, `paddingBottom`

```dart
final panel = Box(
  border: true,
  paddingLeft: 2,
  paddingTop: 1,
  paddingRight: 1,
  paddingBottom: 1,
);
```

## Absolute

`left`, `top` 기반 위치 지정과 `min/max`, margin 제약을 함께 사용할 수 있습니다.
