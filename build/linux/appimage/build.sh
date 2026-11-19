#!/usr/bin/env bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

if [[ "${VSCODE_ARCH}" == "x64" ]]; then
  # Unauthenticated GitHub API calls from Actions runners often hit rate
  # limits (HTTP 403). Prefer an authenticated request, then a known public
  # continuous build URL so Deb/RPM packaging is not blocked.
  PKG2APPIMAGE_FALLBACK_URL="https://github.com/AppImageCommunity/pkg2appimage/releases/download/continuous/pkg2appimage-1eceb30-x86_64.AppImage"

  fetch_pkg2appimage_url() {
    local repo="$1"
    local curl_args=(--silent --location --fail)
    if [[ -n "${GITHUB_TOKEN}" ]]; then
      curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json")
    fi
    local response
    response=$( curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/releases/latest" || true )
    echo "${response}" | jq --raw-output '.assets | map(select( .name | test("x86_64.AppImage(?!.zsync)"))) | map(.browser_download_url)[0] // empty' 2>/dev/null || true
  }

  APPIMAGE_URL=$( fetch_pkg2appimage_url "AppImageCommunity/pkg2appimage" )
  if [[ -z "${APPIMAGE_URL}" || "${APPIMAGE_URL}" == "null" ]]; then
    APPIMAGE_URL=$( fetch_pkg2appimage_url "AppImage/pkg2appimage" )
  fi
  if [[ -z "${APPIMAGE_URL}" || "${APPIMAGE_URL}" == "null" ]]; then
    echo "GitHub API did not return pkg2appimage URL; using fallback ${PKG2APPIMAGE_FALLBACK_URL}"
    APPIMAGE_URL="${PKG2APPIMAGE_FALLBACK_URL}"
  fi

  echo "Downloading pkg2appimage from ${APPIMAGE_URL}"
  wget -c "${APPIMAGE_URL}" -O pkg2appimage.AppImage

  chmod +x ./pkg2appimage.AppImage

  ./pkg2appimage.AppImage --appimage-extract && mv ./squashfs-root ./pkg2appimage.AppDir

  # add update's url
  # Void - this line is important - ask GPT about it
  sed -i 's/generate_type2_appimage/generate_type2_appimage -u "gh-releases-zsync|bimacoding|ZYNTHEO-IDE|latest|*.AppImage.zsync"/' pkg2appimage.AppDir/AppRun

  # remove check so build in docker can succeed
  sed -i 's/grep docker/# grep docker/' pkg2appimage.AppDir/usr/share/pkg2appimage/functions.sh

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i 's|@@NAME@@|Zyntheo-Insiders|g' recipe.yml
    sed -i 's|@@APPNAME@@|zyntheo-insiders|g' recipe.yml
    sed -i 's|@@ICON@@|zyntheo-insiders|g' recipe.yml
  else
    sed -i 's|@@NAME@@|Zyntheo|g' recipe.yml
    sed -i 's|@@APPNAME@@|zyntheo|g' recipe.yml
    sed -i 's|@@ICON@@|zyntheo-editor|g' recipe.yml
  fi

  # workaround that enforces x86 ARCH for pkg2appimage having /__w/vscodium/vscodium/build/linux/appimage/VSCodium/VSCodium.AppDir/usr/share/codium/resources/app/node_modules/rc/index.js is of architecture armhf
  export ARCH=x86_64
  bash -ex pkg2appimage.AppDir/AppRun recipe.yml

  rm -f pkg2appimage-*.AppImage
  rm -rf pkg2appimage.AppDir
  rm -rf Zyntheo* Void*
fi

cd "${CALLER_DIR}"
