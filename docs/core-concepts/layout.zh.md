# Layout

`opentui` 支持 `row`、`column`、`absolute` 布局以及扩展布局属性。

## 方向

- `TuiLayoutDirection.row`
- `TuiLayoutDirection.column`
- `TuiLayoutDirection.absolute`

## 对齐

- `justify`: `TuiJustify.start|center|end|spaceBetween|spaceAround|spaceEvenly`
- `align`: `TuiAlign.start|center|end|stretch`

## 尺寸

- 固定尺寸: `width`, `height`
- 百分比: `widthPercent`, `heightPercent`
- 约束: `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
- 弹性增长: `flexGrow`

## Wrap

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

- `margin`
- `marginX`, `marginY`
- `marginLeft`, `marginTop`, `marginRight`, `marginBottom`

## Padding (Box)

- `padding`
- `paddingX`, `paddingY`
- `paddingLeft`, `paddingTop`, `paddingRight`, `paddingBottom`

## Absolute

绝对布局可同时使用 `left`、`top`、margin、min/max 约束。
