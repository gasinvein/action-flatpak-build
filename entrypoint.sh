#!/bin/bash

set -e
set -o pipefail
shopt -s failglob

FLATPAK_KIND="${INPUT_KIND:-"app"}"
FLATPAK_ID="${INPUT_ID}"
FLATPAK_ARCH="${INPUT_ARCH:-"$(flatpak --default-arch)"}"
FLATPAK_BRANCH="${INPUT_BRANCH:-"stable"}"

if [ -z "$FLATPAK_KIND" ] || \
   [ -z "$FLATPAK_ID" ] || \
   [ -z "$FLATPAK_ARCH" ] || \
   [ -z "$FLATPAK_BRANCH" ]; then
    exit 1
fi

if [ -f "$FLATPAK_ID.json" ]; then
    MANIFEST="$FLATPAK_ID.json"
elif [ -f "$FLATPAK_ID.yml" ]; then
    MANIFEST="$FLATPAK_ID.yml"
elif [ -f "$FLATPAK_ID.yaml" ]; then
    MANIFEST="$FLATPAK_ID.yaml"
else
    exit 1
fi

FP_BUILD_REPO="$(pwd)/build-repo"
FP_BUILD_DIR="$(pwd)/build-dir"

echo "::debug::Building $FLATPAK_KIND/$FLATPAK_ID/$FLATPAK_ARCH/$FLATPAK_BRANCH from $MANIFEST"

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak-builder --install-deps-from=flathub --install-deps-only --user /dev/null "$MANIFEST"
flatpak-builder --download-only /dev/null "$MANIFEST"
flatpak-builder --disable-updates --disable-download --ccache --sandbox \
                --repo="${FP_BUILD_REPO}" "${FP_BUILD_DIR}" "$MANIFEST"

echo "::set-output name=build_dir::${FP_BUILD_DIR}"
echo "::set-output name=build_repo::${FP_BUILD_REPO}"
