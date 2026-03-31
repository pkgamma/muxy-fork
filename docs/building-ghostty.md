# Building libghostty

Muxy depends on libghostty compiled as a static library inside `GhosttyKit.xcframework/`. The xcframework is checked into the repo, but you'll need to rebuild it when updating the ghostty submodule or making changes to libghostty.

## Prerequisites

- macOS 14+
- Xcode with `xcodebuild` available
- Zig (check `ghostty/build.zig.zon` for the minimum version)

## Build Commands

### Universal build (arm64 + x86_64, includes iOS targets)

```bash
cd ghostty
zig build -Demit-xcframework=true -Dxcframework-target=universal
```

This produces the xcframework at `ghostty/macos/GhosttyKit.xcframework/` containing:
- `macos-arm64_x86_64/libghostty.a` — universal macOS binary
- `ios-arm64/libghostty-fat.a` — iOS device
- `ios-arm64-simulator/libghostty-fat.a` — iOS simulator

### Native-only build (faster, for development)

```bash
cd ghostty
zig build -Demit-xcframework=true -Dxcframework-target=native
```

Builds only for your host architecture — significantly faster for iteration.

### Skip the macOS app (library only)

```bash
cd ghostty
zig build -Demit-xcframework=true -Demit-macos-app=false
```

## Updating Muxy's xcframework

After building, copy the output into the Muxy repo root:

```bash
cp -R ghostty/macos/GhosttyKit.xcframework ./GhosttyKit.xcframework
```

Muxy's `Package.swift` links against `GhosttyKit.xcframework/macos-arm64_x86_64/libghostty.a`.

## How the build works

1. `GhosttyLib.zig` compiles libghostty as a static library per target architecture
2. For macOS universal, it builds arm64 and x86_64 separately then merges with `lipo`
3. `XCFrameworkStep.zig` runs `xcodebuild -create-xcframework` to package all platform libraries with their headers (from `ghostty/include/`)
4. The result is a standard Apple xcframework usable by SPM

## Updating the ghostty submodule

```bash
cd ghostty
git fetch origin
git checkout <desired-commit-or-tag>
cd ..
git add ghostty
```

Then rebuild the xcframework and copy it over as described above.
