# OpenTUI Parity Checklist (`packages/opentui`, `packages/flutter_opentui`)

Last updated: 2026-02-22  
Reference baseline: `ref/opentui/packages/core`

Status legend:
- `done`: behavior/API is intentionally aligned
- `in-progress`: partially implemented, not parity-complete
- `missing`: major parity gap

## Critical Track (Step 3 priority)

| Area | Status | Notes |
| --- | --- | --- |
| Core API surface parity (`index.ts` level) | `in-progress` | Dart exposes core engine/renderables and now includes `TextNode`/`TextBuffer` renderable surfaces, but ref-level runtime contracts and editor/native stacks are still partial. |
| Input/event model parity (key/mouse/propagation/selection) | `in-progress` | Key metadata/paste + mouse stream + propagation flags exist. Key dispatch now bubbles through parent chain, Tab default focus change honors `preventDefault()`, and core drag-selection lifecycle is wired. Ref-level per-renderable notification semantics remain broader. |
| Render pipeline parity (Yoga/native/scissor/opacity/hit-grid) | `missing` | Current Dart engine is a pure Dart layout/paint path and does not yet match ref native command pipeline semantics. |

## Core Surface

| Item | Status | Notes |
| --- | --- | --- |
| `createCliRenderer()` + `CliRenderer` | `in-progress` | Exists, but options/runtime behavior are narrower than ref renderer config and lifecycle. |
| Terminal adapter (raw input + resize + ANSI diff) | `in-progress` | Supports key parsing, paste, resize, and now SGR mouse parsing. Still not full ref terminal capability stack. |
| Event objects (`Key`, `Paste`, `Mouse`) | `in-progress` | Added mutable event control flags and mouse model. Ref-level event priority/dispatch semantics remain broader. |
| Selection model | `in-progress` | Engine now provides global selection state/stream with drag lifecycle and frame overlay. Ref-equivalent renderable-level selection coupling is still incomplete. |
| Text model (`TextNode`, `TextBuffer` surface) | `in-progress` | Basic Dart renderable APIs now exist (`TextNodeRenderable`, `TextBufferRenderable`) with simplified behavior; ref text-buffer internals are broader. |
| Console overlay | `in-progress` | Functional overlay exists in Dart renderer, but behavior/features differ from ref console pipeline. |

## Component Parity

| Component | Status | Notes |
| --- | --- | --- |
| `Box`, `Text`, `Input`, `Textarea`, `Select`, `TabSelect` | `in-progress` | Present and interactive. Advanced keybinding/action/event contracts from ref are not fully mirrored. |
| `ScrollBox`, `ScrollBar`, `Slider` | `in-progress` | Present with keyboard + basic mouse interactions. Ref sticky/auto-scroll/acceleration/selection-coupling is incomplete. |
| `Markdown`, `Code`, `Diff`, `LineNumber` | `in-progress` | Present, but Markdown/Code are simplified vs ref parser/tree-sitter/syntax style behavior. |
| `ASCIIFont`, `FrameBuffer` | `in-progress` | Present; still not equivalent to ref full rendering/selection capabilities. |

## Flutter Bridge Parity

| Item | Status | Notes |
| --- | --- | --- |
| `OpenTuiView` keyboard bridge | `done` | Key mapping and character/paste forwarding are wired. |
| `OpenTuiView` pointer bridge | `in-progress` | Mouse down/move/up/scroll forwarding added in this phase; gesture parity with ref remains broader. |
| Flutter rendering output parity | `in-progress` | Cell painter works, but ref native runtime semantics are not fully matched. |

## Step 1 Baseline Rules (frozen for refactor)

1. Any row marked `in-progress` or `missing` cannot be claimed as parity complete.
2. “Component exists” is not enough; keybindings, events, selection, and render semantics must match.
3. Parity closure requires behavior tests, not only API presence.

## Active Refactor Scope (Step 3 started)

Completed in this phase:
- Added mouse event channel to `TuiInputSource` and all adapters.
- Added event-level `preventDefault`/`stopPropagation` primitives.
- Wired pointer events from Flutter (`OpenTuiView`) to engine.
- Added initial engine mouse hit-test and bubbling dispatch.
- Added basic mouse behavior for interactive nodes (`Input`, `Textarea`, `Select`, `TabSelect`, `ScrollBox`, `ScrollBar`, `Slider`).
- Added key bubbling dispatch in engine and made Tab focus-cycle default preventable.
- Added `TextNode` / `TextBuffer` renderable + construct API surfaces.
- Added regression tests for mouse interaction (`opentui`) and pointer bridge/controller (`flutter_opentui`).
- Added core selection model (`TuiSelectionRange`) and engine selection lifecycle (start/drag/end/clear + stream).
- Added selection overlay rendering in engine and dedicated selection regression tests.

Remaining in Step 3:
- Ref-style renderable selection notifications and advanced selection coupling.
- Full renderer pipeline parity (scissor/opacity/hit-grid/native behavior).
- Advanced keybinding/action parity for text/edit/select family.
