# CC18 iPad — iOS 18 visual upgrade

The updated RootHide/arm64e source bundle is stored in `CC18iPad-iOS18-visual-upgrade.zip` (folder `CC18iPad/` inside the archive). It contains the complete project: Theos Makefile, Logos tweak source, SpringBoard filter plist, Debian control metadata and detailed README.

Target: iPad 9 (A13), iPadOS 15.x, Dopamine RootHide. Package version: 0.6.2.

## Build
The GitHub Actions workflow builds the archive contents with RootHide Theos. The local wrapper also supports:
`make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide`

## Scope and limitations
This is a visual/behavioral restyle of the iPadOS 15 Control Center, not a port of the newer iOS 18 Control Center framework. Existing iPadOS 15 controls remain underneath; the iOS 18 edit gallery, drag-and-resize grid and native pages are not implemented.
