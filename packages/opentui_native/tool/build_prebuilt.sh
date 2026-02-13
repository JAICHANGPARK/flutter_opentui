#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_DIR="$ROOT_DIR/../../ref/opentui/packages/core/src/zig"
OUT_DIR="$ROOT_DIR/native"
FORCE=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --force)
      FORCE=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if ! command -v zig >/dev/null 2>&1; then
  echo "zig not found. Install Zig first." >&2
  exit 1
fi

if [[ ! -d "$UPSTREAM_DIR" ]]; then
  echo "Upstream Zig source not found: $UPSTREAM_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# os/arch | zig target | zig lib output folder
TARGETS=(
  "macos/arm64|aarch64-macos|aarch64-macos"
  "macos/x64|x86_64-macos|x86_64-macos"
  "linux/arm64|aarch64-linux|aarch64-linux"
  "linux/x64|x86_64-linux|x86_64-linux"
  "windows/x64|x86_64-windows-gnu|x86_64-windows"
  "android/arm64|aarch64-linux-android|aarch64-linux-android"
)

built_count=0

for target in "${TARGETS[@]}"; do
  IFS='|' read -r out_platform zig_target zig_output <<< "$target"

  out_path="$OUT_DIR/$out_platform"
  mkdir -p "$out_path"

  if [[ "$out_platform" == windows/* ]]; then
    lib_name="opentui_native.dll"
    src_name="opentui.dll"
  elif [[ "$out_platform" == macos/* || "$out_platform" == ios/* ]]; then
    lib_name="libopentui_native.dylib"
    src_name="libopentui.dylib"
  else
    lib_name="libopentui_native.so"
    src_name="libopentui.so"
  fi

  dst="$out_path/$lib_name"

  if [[ -f "$dst" && $FORCE -ne 1 ]]; then
    echo "skip $out_platform (exists): $dst"
    continue
  fi

  echo "build $out_platform <- $zig_target"
  if [[ $DRY_RUN -eq 0 ]]; then
    (
      cd "$UPSTREAM_DIR"
      zig build -Doptimize=ReleaseFast -Dtarget="$zig_target"
    )

    src="$UPSTREAM_DIR/lib/$zig_output/$src_name"
    if [[ ! -f "$src" ]]; then
      echo "missing built output: $src" >&2
      exit 1
    fi

    cp "$src" "$dst"
  fi

  built_count=$((built_count + 1))
done

# Mobile folders are retained for packaging; actual iOS/Android build flow is platform SDK specific.
mkdir -p "$OUT_DIR/android/arm64" "$OUT_DIR/ios/arm64"
: > "$OUT_DIR/android/arm64/.gitkeep"
: > "$OUT_DIR/ios/arm64/.gitkeep"

if [[ $DRY_RUN -eq 0 ]]; then
  echo "iOS binary build is not handled by this script (requires Apple SDK toolchain)."
fi

if [[ $DRY_RUN -eq 0 ]]; then
  (
    cd "$OUT_DIR"
    find android ios linux macos windows -type f \
      ! -name 'checksums.sha256' \
      ! -name 'README.md' \
      | sort \
      | while read -r f; do shasum -a 256 "$f"; done \
      > checksums.sha256
  )
fi

echo "done. built targets: $built_count"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "dry-run mode: no files were compiled/copied"
fi
