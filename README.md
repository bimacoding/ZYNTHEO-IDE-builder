# Zyntheo IDE Builder

This packaging pipeline is derived from VSCodium / Void Builder and now builds **Zyntheo IDE** independently.

It clones [`bimacoding/ZYNTHEO-IDE`](https://github.com/bimacoding/ZYNTHEO-IDE), produces desktop assets via GitHub Actions, publishes them to [`bimacoding/ZYNTHEO-IDE` releases](https://github.com/bimacoding/ZYNTHEO-IDE/releases), and writes update metadata to [`bimacoding/ZYNTHEO-IDE-versions`](https://github.com/bimacoding/ZYNTHEO-IDE-versions).

Zyntheo no longer depends on `voideditor/void`, `voideditor/binaries`, or `voideditor/versions`.

## Notes

- Workflows: `stable-macos.yml`, `stable-linux.yml`, `stable-windows.yml`
- Source checkout: `get_repo.sh` clones `bimacoding/ZYNTHEO-IDE`
- Product identity comes from Zyntheo `product.json` (`zyntheoVersion` / `zyntheoRelease`)
- macOS Intel builds use `macos-15-intel` (GitHub retired `macos-13`)

## Code signing and notarization

Unsigned / ad-hoc builds still run, but Gatekeeper on macOS and SmartScreen on Windows will warn until certificates are installed.

### macOS Developer ID + notarize

`prepare_assets.sh` signs and notarizes automatically when these GitHub Actions secrets exist on `ZYNTHEO-IDE-builder`:

| Secret | Value |
|--------|--------|
| `CERTIFICATE_OSX_NEW_P12_DATA` | Base64 of the Developer ID Application `.p12` |
| `CERTIFICATE_OSX_NEW_P12_PASSWORD` | Password for that `.p12` |
| `CERTIFICATE_OSX_NEW_ID` | Apple ID email |
| `CERTIFICATE_OSX_NEW_TEAM_ID` | Apple Developer Team ID |
| `CERTIFICATE_OSX_NEW_APP_PASSWORD` | [App-specific password](https://support.apple.com/en-us/102654) |

After the secrets are set, re-run `stable-macos.yml` with `generate_assets=true` (or a full deploy). Without them the workflow still produces DMG/ZIP, ad-hoc signed only.

### Windows Authenticode

Windows signing is ready in `stable-windows.yml` but commented until SignPath (or another Authenticode provider) is configured. Required secrets:

| Secret | Value |
|--------|--------|
| `SIGNPATH_API_TOKEN` | SignPath API token |
| `SIGNPATH_ORGANIZATION_ID` | SignPath organization id |
| `SIGNPATH_PROJECT_SLUG` | SignPath project slug |
| `SIGNPATH_POLICY_SLUG` | SignPath signing policy slug |

Uncomment the `Upload unsigned artifacts` and `Signing` steps in `stable-windows.yml` after those secrets exist. Do not enable them empty: the job will fail.

## Heritage

This repository started from [voideditor/void-builder](https://github.com/voideditor/void-builder) (itself a VSCodium fork) and left that GitHub fork network on 2026-11-19 (`isFork: false`). Runtime and packaging now target Zyntheo only.
