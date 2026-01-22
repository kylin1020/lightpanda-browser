#!/bin/bash
# Build script for curl-impersonate Chrome version
# This builds libcurl-impersonate-chrome for use with Lightpanda browser

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CURL_IMPERSONATE_DIR="$ROOT_DIR/vendor/curl-impersonate"
BUILD_DIR="$ROOT_DIR/.lp-cache/curl-impersonate"
INSTALL_DIR="$BUILD_DIR/install"

echo "==> curl-impersonate build script"
echo "    Source: $CURL_IMPERSONATE_DIR"
echo "    Build:  $BUILD_DIR"
echo "    Install: $INSTALL_DIR"

# Check dependencies
check_deps() {
    local missing=()
    command -v go >/dev/null 2>&1 || missing+=("go")
    command -v cmake >/dev/null 2>&1 || missing+=("cmake")
    command -v make >/dev/null 2>&1 || missing+=("make")
    command -v autoconf >/dev/null 2>&1 || missing+=("autoconf")
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo "ERROR: Missing dependencies: ${missing[*]}"
        echo "Install with:"
        echo "  macOS: brew install go cmake autoconf automake libtool"
        echo "  Ubuntu: sudo apt install golang-go cmake autoconf automake libtool"
        exit 1
    fi
    echo "==> All dependencies found"
}

# Build
build_chrome() {
    mkdir -p "$BUILD_DIR" "$INSTALL_DIR"
    
    if [ -f "$INSTALL_DIR/lib/libcurl-impersonate-chrome.a" ]; then
        echo "==> Library already exists at $INSTALL_DIR/lib/libcurl-impersonate-chrome.a"
        echo "==> Skipping build. Use 'clean' to rebuild."
        return 0
    fi
    
    cd "$CURL_IMPERSONATE_DIR"
    
    if [ ! -f "Makefile" ]; then
        echo "==> Running configure..."
        ./configure --prefix="$INSTALL_DIR"
    fi
    
    echo "==> Building Chrome target (this may take a while)..."
    make chrome-build -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    
    echo "==> Installing..."
    make chrome-install DESTDIR=""
    
    echo "==> Done! Library installed to: $INSTALL_DIR"
}

case "${1:-build}" in
    build) check_deps && build_chrome ;;
    check) check_deps ;;
    clean) rm -rf "$BUILD_DIR" ;;
    *) echo "Usage: $0 [build|check|clean]" ;;
esac
