## 0.2.0

- Expanded component coverage to match OpenTUI docs:
  `Box`, `Text`, `Input`, `Textarea`, `Select`, `TabSelect`, `ASCIIFont`,
  `FrameBuffer`, `Markdown`, `Code`, `Diff`, `LineNumber`, `ScrollBox`,
  `Scrollbar`, and `Slider`.
- Added `CliRenderer` parity improvements:
  environment-based theme auto-detection and in-frame console overlay
  composition with keyboard controls (toggle/focus/scroll/size).
- Added construct API parity helpers:
  `instantiate(...)` and `delegate(...)`.
- Extended layout engine with advanced options:
  wrap, min/max constraints, margin shorthands/per-edge margins,
  and per-edge paddings.
- Added and expanded tests across component rendering, events/paste metadata,
  console/theme behavior, and advanced layout.

## 0.1.0

- Initial preview release.
- Added `TuiEngine`, frame model, ANSI diff renderer, and terminal adapter.
- Added primitive nodes: `TuiText`, `TuiBox`, `TuiInput`, `TuiSelect`.
