#!/usr/bin/env bash

BRANCH="test"

rm -f tech.feliciano.pocket-casts.flatpak
rm -rf _build ; mkdir _build
rm -rf _repo ; mkdir _repo

flatpak-builder --ccache --force-clean --default-branch="$BRANCH" _build tech.feliciano.pocket-casts.yml --repo=_repo
flatpak build-bundle _repo tech.feliciano.pocket-casts.flatpak tech.feliciano.pocket-casts "$BRANCH"
