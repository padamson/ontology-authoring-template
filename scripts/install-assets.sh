#!/usr/bin/env bash
# scripts/install-assets.sh
#
# Generate the mdbook-admonish + mdbook-listings CSS/JS assets the book
# needs to build. These are produced (not source) files — intentionally
# gitignored (see .gitignore) — so a fresh clone has neither and a bare
# `cd book && mdbook build` fails on the missing `mdbook-admonish.css`
# until this runs once.
#
# Run it once after cloning (and any time the assets go missing). The
# dev loop (scripts/dev.sh) regenerates them on its own, so you only need
# this for the standalone `mdbook build` / `mdbook serve` path.
#
# Assumes `mdbook-admonish` and `mdbook-listings` are already installed
# and on PATH — see README "Toolchain -> Install" (both come from Git;
# the admonish one from the feat/mdbook-0.5-compat fork branch). This
# script only generates the book assets from those binaries; it does not
# install the binaries themselves. Mirrors the "Restore book assets" step
# in .github/workflows/docs.yml, which likewise relies on PATH.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)/book"

mdbook-admonish install .
mdbook-listings install
