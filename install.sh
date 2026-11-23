#!/bin/sh
# install.sh — standalone installer for HTPL (Hyper Text Programming Language).
#
# ONE script for Linux, macOS and Windows — OpenCode-style:
#
#   curl -fsSL https://raw.githubusercontent.com/HTPLorg/htpl/main/install.sh | sh
#   # or, after downloading:
#   sh install.sh
#   sh install.sh --prefix /usr/local/bin     # needs write access there (e.g. sudo)
#
# Windows runs it under Git Bash (uname reports MINGW64 / MSYS / CYGWIN);
# the binary installed is htpl.exe, into ~/.local/bin — which under Git
# Bash is %USERPROFILE%\.local\bin. Add that folder to your Windows user
# PATH (see the note printed at the end of a Windows install) and open a
# new terminal, then run: htpl --version
#
# Installs the prebuilt `htpl` binary for your OS/arch into ~/.local/bin
# (override with --prefix / --install-dir, or INSTALL_DIR).
#
# The release: v1.1.0 on GitHub (HTPLorg/htpl). NOTE: the release tag is
# 1.1.0 but the binary inside it prints `htpl 1.0.0` — the tag and the
# binary's own version string differ; that is the state of the release,
# not an installer error.
#
# Environment variables:
#   HTPL_INSTALL_BASE   Base URL (or file:// path) holding the release files.
#                       Default: https://github.com/HTPLorg/htpl/releases/download/v$HTPL_VERSION
#   HTPL_VERSION        Release version to install (default: 1.1.0).
#                       The checksums embedded below cover v1.1.0 only; to
#                       install another version, point HTPL_INSTALL_BASE at
#                       a mirror that publishes a SHA256SUMS file.
#   INSTALL_DIR         Install directory (same as --prefix; flag wins).
#
# Files expected at $HTPL_INSTALL_BASE (one zip per platform):
#   htpl-linux-x86_64.zip     Linux x86_64, contains `htpl`
#   htpl-macos-arm64.zip      macOS arm64 (Apple Silicon), contains `htpl`
#   htpl-windows-x86_64.zip   Windows x86_64, contains `htpl.exe`
# No linux-aarch64 and no macOS-x86_64 asset exists — those platforms
# fail honestly, naming the missing asset, instead of installing the
# wrong thing.
#
# Checksums: the v1.1.0 release publishes no SHA256SUMS file, so the
# installer verifies each zip against a SHA-256 embedded below (computed
# from the published v1.1.0 assets). A mirror that publishes SHA256SUMS
# is honoured instead when one is present at the base URL.
#
# Requirements at install time: curl or wget, sha256sum (or shasum -a 256
# on macOS), unzip, and standard coreutils. No npm, cargo, or python
# needed. The installer verifies the download and REFUSES to install on
# a checksum mismatch (non-zero exit, bad file deleted).
#
# Usage:
#   install.sh [--help] [--dry-run] [--prefix DIR | --install-dir DIR]
#              [--base-url URL]
#
set -eu

PROG="install.sh"
VERSION="${HTPL_VERSION:-1.1.0}"
BASE="${HTPL_INSTALL_BASE:-https://github.com/HTPLorg/htpl/releases/download/v$VERSION}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
DRY_RUN=0

die() { printf '%s: error: %s\n' "$PROG" "$*" >&2; exit 1; }
say() { printf '%s: %s\n' "$PROG" "$*"; }

usage() {
    cat <<EOF
Usage: install.sh [OPTIONS]

Install the prebuilt htpl binary for this machine (Linux, macOS, Windows).

Options:
  --help                  Show this help and exit.
  --dry-run               Print what would be installed, without downloading.
  --prefix DIR            Install directory (default: ~/.local/bin).
  --install-dir DIR       Same as --prefix.
  --base-url URL          Release base URL (default: \$HTPL_INSTALL_BASE or
                          https://github.com/HTPLorg/htpl/releases/download/v\$HTPL_VERSION).

Environment variables:
  HTPL_INSTALL_BASE       Release base URL (or file:// directory).
  HTPL_VERSION            Release version to install (default: 1.1.0).
  INSTALL_DIR             Install directory (default: \$HOME/.local/bin).

The installer downloads the zip for your platform, verifies its SHA-256
checksum (embedded for v1.1.0, or from SHA256SUMS when the base URL
publishes one), extracts the binary and installs it as
<install-dir>/htpl (htpl.exe on Windows). A checksum mismatch or an
unreachable base aborts with a non-zero exit and installs nothing.

Windows: run this under Git Bash. The binary lands in
~/.local/bin (=%USERPROFILE%\\.local\\bin); add that folder to your
Windows user PATH and open a new terminal.
EOF
}

# --- argument parsing -------------------------------------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --dry-run) DRY_RUN=1; shift ;;
        --prefix|--install-dir)
            [ $# -ge 2 ] || die "--prefix needs a directory argument"
            INSTALL_DIR="$2"; shift 2 ;;
        --prefix=*|--install-dir=*)
            INSTALL_DIR="${1#*=}"; shift ;;
        --base-url)
            [ $# -ge 2 ] || die "--base-url needs a URL argument"
            BASE="$2"; shift 2 ;;
        --base-url=*)
            BASE="${1#*=}"; shift ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
done

# --- platform detection -----------------------------------------------------
OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS" in
    Linux)  OS_ID="linux" ;;
    Darwin) OS_ID="darwin" ;;
    MINGW*|MSYS*|CYGWIN*) OS_ID="windows" ;;
    *) die "unsupported OS: $OS (this installer covers Linux, macOS and Windows via Git Bash)" ;;
esac
case "$ARCH" in
    x86_64|amd64) ARCH_ID="x86_64" ;;
    arm64|aarch64) ARCH_ID="aarch64" ;;
    *) die "unsupported architecture: $ARCH (supported: x86_64, aarch64)" ;;
esac
case "$OS_ID-$ARCH_ID" in
    linux-x86_64)   ASSET="htpl-linux-x86_64.zip";   INNER="htpl";     BIN="htpl" ;;
    darwin-aarch64) ASSET="htpl-macos-arm64.zip";    INNER="htpl";     BIN="htpl" ;;
    windows-x86_64) ASSET="htpl-windows-x86_64.zip"; INNER="htpl.exe"; BIN="htpl.exe" ;;
    linux-aarch64)   die "no release asset for Linux aarch64 (htpl-linux-aarch64.zip does not exist in v$VERSION) — build from source, or use an x86_64 machine" ;;
    darwin-x86_64)   die "no release asset for macOS x86_64 (htpl-macos-x86_64.zip does not exist in v$VERSION) — the macOS build is arm64 (Apple Silicon) only" ;;
    windows-aarch64) die "no release asset for Windows arm64 (htpl-windows-arm64.zip does not exist in v$VERSION)" ;;
    *) die "unsupported platform: $OS_ID-$ARCH_ID (no release asset in v$VERSION)" ;;
esac

DEST="$INSTALL_DIR/$BIN"

if [ "$DRY_RUN" -eq 1 ]; then
    cat <<EOF
HTPL installer (dry run — nothing will be downloaded or installed)
  OS / arch:      $OS / $ARCH
  platform:       $OS_ID-$ARCH_ID
  version:        $VERSION
  base URL:       $BASE
  asset:          $ASSET (contains $INNER)
  install to:     $DEST
Would download $BASE/$ASSET, verify its SHA-256 checksum, extract $INNER
and install it as $DEST.
EOF
    exit 0
fi

# --- prerequisites ----------------------------------------------------------
if command -v curl >/dev/null 2>&1; then
    DL="curl"
elif command -v wget >/dev/null 2>&1; then
    DL="wget"
else
    die "need curl or wget to download the release (neither found in PATH)"
fi
if command -v sha256sum >/dev/null 2>&1; then
    HASHER="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
    HASHER="shasum -a 256"
else
    die "need sha256sum or shasum to verify the download (neither found in PATH)"
fi
command -v unzip >/dev/null 2>&1 || die "need unzip to extract the release zip (not found in PATH)"

# --- checksums embedded for the published v1.1.0 assets --------------------
# Computed from the release files at
# https://github.com/HTPLorg/htpl/releases/download/v1.1.0/
# (the release publishes no SHA256SUMS file).
embedded_sha256() {
    case "$1" in
        htpl-linux-x86_64.zip)   printf '%s' "d8345e0e75f149cf557c71ed4b760cb9d195931b34c5e4e214156ebc97a36ae2" ;;
        htpl-macos-arm64.zip)    printf '%s' "53f79d4a8911150375f375c1ca8ac2d4149e18ad6b7888f52ec5409b32b1dcbc" ;;
        htpl-windows-x86_64.zip) printf '%s' "20dcdd62fbbfc3909e89a7e3cb6185635c90572818ee1a25d2bdc2f34a4e360b" ;;
        *) printf '%s' "" ;;
    esac
}

# --- download ---------------------------------------------------------------
TMPDIR_WORK="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WORK"' EXIT INT TERM
ZIP_PATH="$TMPDIR_WORK/$ASSET"
SUMS_PATH="$TMPDIR_WORK/SHA256SUMS"

# Strip a trailing slash so "$BASE/$ASSET" never has "//".
case "$BASE" in */) BASE="${BASE%/}" ;; esac

download() {
    # $1 = URL, $2 = destination file. file:// bases are plain copies.
    case "$1" in
        file://*)
            src="${1#file://}"
            [ -f "$src" ] || return 1
            cp "$src" "$2" || return 1
            ;;
        *)
            if [ "$DL" = "curl" ]; then
                curl -fsSL --connect-timeout 15 --max-time 300 "$1" -o "$2" || return 1
            else
                wget -q --timeout=15 -O "$2" "$1" || return 1
            fi
            ;;
    esac
}

say "downloading $ASSET (HTPL $VERSION, $OS_ID-$ARCH_ID) from $BASE ..."
if ! download "$BASE/$ASSET" "$ZIP_PATH"; then
    die "download failed: could not fetch $BASE/$ASSET — check that version $VERSION is published there and that your platform has an asset (Linux x86_64, macOS arm64, Windows x86_64 only)"
fi

# --- checksum verification --------------------------------------------------
# Prefer a SHA256SUMS file at the base when one exists (mirrors / other
# versions); otherwise use the checksum embedded above for v1.1.0.
EXPECTED=""
SUMS_SOURCE=""
if download "$BASE/SHA256SUMS" "$SUMS_PATH" 2>/dev/null; then
    EXPECTED="$(awk -v f="$ASSET" '$2 == f { print $1; exit }' "$SUMS_PATH")"
    [ -n "$EXPECTED" ] && SUMS_SOURCE="SHA256SUMS from $BASE"
fi
if [ -z "$EXPECTED" ]; then
    EXPECTED="$(embedded_sha256 "$ASSET")"
    SUMS_SOURCE="embedded checksum (v1.1.0 release)"
fi
if [ -z "$EXPECTED" ]; then
    rm -f "$ZIP_PATH"
    die "checksum verification failed: no checksum available for $ASSET — the embedded checksums cover v1.1.0 only; to install another version, point HTPL_INSTALL_BASE at a mirror that publishes SHA256SUMS"
fi
ACTUAL="$($HASHER "$ZIP_PATH" | awk '{ print $1 }')"
if [ "$ACTUAL" != "$EXPECTED" ]; then
    rm -f "$ZIP_PATH"
    die "checksum mismatch for $ASSET: expected $EXPECTED, got $ACTUAL — refusing to install (bad download deleted). If you are installing a version other than v1.1.0, point HTPL_INSTALL_BASE at a mirror that publishes SHA256SUMS"
fi
say "checksum OK ($ASSET matches $SUMS_SOURCE)"

# --- extract and install ----------------------------------------------------
EXTRACT_DIR="$TMPDIR_WORK/extract"
mkdir -p "$EXTRACT_DIR" || die "cannot create work directory $EXTRACT_DIR"
if ! unzip -o -q "$ZIP_PATH" "$INNER" -d "$EXTRACT_DIR"; then
    die "could not extract $INNER from $ASSET — the download may be corrupt (checksum passed, so please report this as a bug)"
fi
[ -f "$EXTRACT_DIR/$INNER" ] || die "extraction failed: $INNER not found inside $ASSET"

mkdir -p "$INSTALL_DIR" || die "cannot create install directory $INSTALL_DIR"
cp "$EXTRACT_DIR/$INNER" "$DEST" || die "cannot copy binary to $DEST"
chmod 755 "$DEST" || die "cannot make $DEST executable"

# --- report -----------------------------------------------------------------
VER_OUTPUT="$("$DEST" --version 2>&1 | head -n 1 || true)"
if [ -n "$VER_OUTPUT" ]; then
    say "installed: $VER_OUTPUT"
else
    say "installed: $DEST (HTPL $VERSION, $OS_ID-$ARCH_ID)"
fi
say "run: $BIN --version"
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        if [ "$OS_ID" = "windows" ]; then
            if command -v cygpath >/dev/null 2>&1; then
                WIN_DIR="$(cygpath -w "$INSTALL_DIR")"
            else
                WIN_DIR="$INSTALL_DIR (under %USERPROFILE%)"
            fi
            say "note: $INSTALL_DIR is not on your PATH — in Windows, add $WIN_DIR to your user PATH (Settings > System > About > Advanced system settings > Environment Variables), then open a new terminal and run: htpl --version"
        else
            say "note: $INSTALL_DIR is not on your PATH — add it with: export PATH=\"\$PATH:$INSTALL_DIR\""
        fi
        ;;
esac
