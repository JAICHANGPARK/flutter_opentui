# Layout

`opentui` は `row` / `column` / `absolute` レイアウトと拡張レイアウト属性をサポートします。

## 方向

- `TuiLayoutDirection.row`
- `TuiLayoutDirection.column`
- `TuiLayoutDirection.absolute`

## 整列

- `justify`: `TuiJustify.start|center|end|spaceBetween|spaceAround|spaceEvenly`
- `align`: `TuiAlign.start|center|end|stretch`

## サイズ

- 固定: `width`, `height`
- パーセント: `widthPercent`, `heightPercent`
- 制約: `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
- 可変: `flexGrow`

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

`left`, `top`, margin, min/max を同時に使えます。
