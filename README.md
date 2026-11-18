# Zyntheo IDE Builder

This packaging pipeline is derived from VSCodium / Void Builder and now builds **Zyntheo IDE** independently.

It clones [`bimacoding/ZYNTHEO-IDE`](https://github.com/bimacoding/ZYNTHEO-IDE), produces desktop assets via GitHub Actions, publishes them to [`bimacoding/ZYNTHEO-IDE` releases](https://github.com/bimacoding/ZYNTHEO-IDE/releases), and writes update metadata to [`bimacoding/ZYNTHEO-IDE-versions`](https://github.com/bimacoding/ZYNTHEO-IDE-versions).

Zyntheo no longer depends on `voideditor/void`, `voideditor/binaries`, or `voideditor/versions`.

## Notes

- Workflows: `stable-macos.yml`, `stable-linux.yml`, `stable-windows.yml`
- Source checkout: `get_repo.sh` clones `bimacoding/ZYNTHEO-IDE`
- Product identity comes from Zyntheo `product.json` (`zyntheoVersion` / `zyntheoRelease`)

## Heritage

This repository started as a fork of [voideditor/void-builder](https://github.com/voideditor/void-builder) (itself a VSCodium fork). Runtime and packaging now target Zyntheo only.
