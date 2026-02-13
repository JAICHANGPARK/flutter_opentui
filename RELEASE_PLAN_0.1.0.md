# OpenTUI 0.1.0 Publish Plan

Date: 2026-02-13

## Package order

1. Publish `opentui_native` (`packages/opentui_native`) first.
2. Publish `opentui_max` (`packages/opentui_max`) second.

## Commands

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui

dart run melos bootstrap
dart run melos run analyze
dart run melos run test
dart run melos run verify:native
dart run melos run verify:parity

cd /Users/jaichang/Documents/GitHub/flutter_opentui/packages/opentui_native
dart pub publish --dry-run
dart pub publish

cd /Users/jaichang/Documents/GitHub/flutter_opentui/packages/opentui_max
dart pub publish --dry-run
dart pub publish
```

## Notes

- `opentui_native`: Web 미지원(FFI 제약).
- `opentui_max`: CLI + Flutter Desktop/Mobile/Web 지원 정책 유지.
- 두 패키지는 상호 의존하지 않는다.
