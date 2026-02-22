# OpenTUI Parity Checklist (`packages/opentui`)

Source truth:
- `ref/opentui/packages/core/docs/getting-started.md`
- `ref/opentui/packages/core/docs/renderables-vs-constructs.md`
- `packages/opentui_max/tool/parity_manifest.yaml` (web component docs list)

Status legend: `done`, `in-progress`, `planned`

## Core concepts

| Item | Status | Notes |
| --- | --- | --- |
| `CliRenderer` + `createCliRenderer()` | `done` | Added in `src/cli_renderer.dart` with root mount/render lifecycle wrapper. |
| Theme mode API (`dark`/`light`/`null`) | `done` | Added nullable mode + stream/listener API plus environment/terminal heuristics via `detectThemeModeFromEnvironment()` when `themeMode` is not explicitly provided. |
| FrameBuffer primitives | `done` | `TuiFrame`, `OptimizedBuffer`, `FrameBufferRenderable`/`TuiFrameBufferNode` available. |
| Renderables tree model | `done` | Base renderable + node conversion exists for core and expanded component set. |
| Built-in console API | `done` | Console model/controller now renders as an in-frame overlay in `CliRenderer` with key handling for toggle/focus/scroll/size and visible entry lines. |
| Keyboard events + paste | `done` | Added metadata fields (`name`, `sequence`, `meta`, `option`) and paste event representation (`TuiPasteEvent`). |

## Components

| Component | Status | Notes |
| --- | --- | --- |
| Box | `done` | `TuiBox` / `BoxRenderable` |
| Text | `done` | `TuiText` / `TextRenderable` |
| Input | `done` | `TuiInput` / `InputRenderable` |
| Select | `done` | `TuiSelect` / `SelectRenderable` |
| TabSelect | `done` | `TuiTabSelect` / `TabSelectRenderable` |
| ASCIIFont | `done` | `TuiAsciiFont` / `ASCIIFontRenderable` |
| FrameBuffer | `done` | `TuiFrameBufferNode` / `FrameBufferRenderable` |
| Markdown | `done` | `TuiMarkdown` / `MarkdownRenderable` (minimal markdown stripping). |
| Code | `done` | `TuiCode` / `CodeRenderable` |
| Diff | `done` | `TuiDiff` / `DiffRenderable` (line-based minimal diff formatting). |
| LineNumber | `done` | `TuiLineNumber` / `LineNumberRenderable` |
| ScrollBox | `done` | `TuiScrollBox` / `ScrollBoxRenderable` support focus + keyboard scrolling (`arrow` + `shift` fast-step), clamped offsets, and stable viewport clipping. |
| Scrollbar | `done` | `TuiScrollbar` / `ScrollbarRenderable` include clamped state, configurable step/fast-step keyboard control, and track/thumb rendering for both orientations. |
| Slider | `done` | `TuiSlider` / `SliderRenderable` with arrow-key value changes and track/thumb rendering. |
| Textarea | `done` | `TuiTextarea` / `TextareaRenderable` support multiline editing, vertical cursor movement, and render-time auto-scroll to keep the cursor visible. |

## Constructs / declarative API

| Item | Status | Notes |
| --- | --- | --- |
| Construct factory helpers (`Box`, `Text`, `Input`, etc.) | `done` | Added in `src/constructs.dart`; return renderables and support child composition. |
| Component coverage in constructs | `done` | Includes markdown/code/diff/line-number/scrollbox/scrollbar/slider/textarea helpers. |
| Delegation/instantiation model from ref docs (`delegate`, `instantiate`) | `done` | Added minimal Dart-native `delegate(...)` and `instantiate(...)` APIs for concrete renderables/factories, with delegated descendant routing through `DelegatedRenderable`. |

## Layout capabilities

| Capability | Status | Notes |
| --- | --- | --- |
| Row/column/absolute layout | `done` | Supported in engine (`TuiLayoutDirection`). |
| `flexGrow` distribution | `done` | Existing behavior preserved and covered by tests. |
| Container justify alignment | `done` | Added `TuiJustify` and engine spacing behavior. |
| Container cross-axis align | `done` | Added `TuiAlign` and engine cross-axis placement behavior. |
| Percent sizing (`widthPercent`/`heightPercent`) | `done` | Added to nodes/renderables and integrated into row/column/absolute layout calculations. |
| Advanced Yoga-like features (wrap, min/max, margins, paddings per edge, etc.) | `done` | Added `TuiWrap`, min/max constraints, margin shorthands + per-edge margins, and per-edge paddings with engine layout coverage/tests (`layout_advanced_test.dart`). |
