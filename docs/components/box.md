# Box

레이아웃과 스타일의 기본 컨테이너입니다.

## Construct

```dart
final box = Box(
  id: 'box',
  layoutDirection: TuiLayoutDirection.column,
  wrap: TuiWrap.wrap,
  justify: TuiJustify.start,
  align: TuiAlign.stretch,
  border: true,
  title: 'Panel',
  padding: 1,
  children: <BaseRenderable>[
    Text(content: 'hello'),
  ],
);
```

## 주요 속성

- 레이아웃: `layoutDirection`, `wrap`, `justify`, `align`, `flexGrow`
- 크기: `width`, `height`, `widthPercent`, `heightPercent`
- 제약: `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
- margin: `margin`, `marginX/Y`, `marginLeft/Top/Right/Bottom`
- padding: `padding`, `paddingX/Y`, `paddingLeft/Top/Right/Bottom`
- 스타일: `style`, `borderStyle`, `border`, `title`
