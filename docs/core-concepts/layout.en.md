# Layout

`opentui` supports `row`, `column`, `absolute` layout plus extended layout options.

## Direction

- `TuiLayoutDirection.row`
- `TuiLayoutDirection.column`
- `TuiLayoutDirection.absolute`

## Alignment

- `justify`: `TuiJustify.start|center|end|spaceBetween|spaceAround|spaceEvenly`
- `align`: `TuiAlign.start|center|end|stretch`

## Sizing

- Fixed: `width`, `height`
- Percentage: `widthPercent`, `heightPercent`
- Constraints: `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
- Flexible growth: `flexGrow`

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

You can combine `left`, `top`, margin, and min/max constraints in absolute mode.
