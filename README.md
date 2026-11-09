# iPadOS18CC

Experimental jailbreak tweak project targeting iPad 9th generation (A13), iPadOS 15.6, and RootHide.

## Scope

This repository is a starting implementation for an iOS 18-inspired Control Center appearance and a Home Indicator-style bottom bar. It is **not yet a pixel-perfect port of iOS 18 Control Center**; that requires deeper integration with private Control Center frameworks and device testing.

## Build

Requires Theos and an iOS 15.6-compatible SDK/toolchain.

```sh
make package
```

The GitHub Actions workflow attempts a Theos package build. Verify the resulting package on a test device before installing. Keep a jailbreak recovery/respring method available.

## Target

- Device: iPad (9th generation)
- OS: iPadOS 15.6
- Jailbreak: RootHide
- Package: Debian (`.deb`)

## Features in this initial scaffold

- Adds a configurable-looking Home Indicator overlay (currently fixed dimensions/position).
- Applies an initial rounded, dark translucent treatment to Control Center's root view when the known controller class is present.
- Hook points are intentionally conservative; APIs/classes are private and may differ on a given jailbreak.

## Disclaimer

Private-framework hooks can cause SpringBoard crashes or respring loops. This is experimental software, not an official Apple port.