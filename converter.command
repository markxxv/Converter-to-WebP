#!/bin/zsh
# Process all images: convert AVIF/JPG/JPEG/PNG to WebP, move existing WebP files
# Resize all to max width 1900px and place in ./webp subfolder
# Works on macOS (Apple Silicon & Intel). Installs dependencies automatically via Homebrew if needed.

set -euo pipefail

# --- Move to script directory ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# --- Helper for logging ---
log() { echo "[image-processor] $1"; }

# --- Ensure Command Line Tools (needed for Homebrew) ---
if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Apple Command Line Tools (one-time macOS prompt will appear)..."
    xcode-select --install || true
    log "Please run this tool again after the Command Line Tools finish installing."
    exit 0
fi

# --- Ensure Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for current session
    if [ -d "/opt/homebrew/bin" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
        echo 'export PATH="/opt/homebrew/bin:$PATH"' >> "${HOME}/.zprofile"
    elif [ -d "/usr/local/bin" ]; then
        export PATH="/usr/local/bin:$PATH"
        echo 'export PATH="/usr/local/bin:$PATH"' >> "${HOME}/.zprofile"
    fi
fi

# --- Ensure required tools (ImageMagick + libheif + webp) ---
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v magick >/dev/null 2>&1; then
    log "Installing ImageMagick (with AVIF/HEIF support) and WebP encoders..."
    brew update >/dev/null 2>&1 || true
    brew install imagemagick libheif webp >/dev/null 2>&1 || brew upgrade imagemagick libheif webp >/dev/null 2>&1 || true
fi

if ! command -v magick >/dev/null 2>&1; then
    log "ImageMagick (magick) not found after install. Aborting."
    exit 1
fi

# --- Prepare output folder ---
OUT_DIR="${SCRIPT_DIR}/webp"
mkdir -p "$OUT_DIR"

# --- Process AVIF files ---
log "Searching for .avif files in: $SCRIPT_DIR"
AVIF_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.avif' \) | wc -l | tr -d ' ')

if [ "$AVIF_COUNT" != "0" ]; then
    log "Found ${AVIF_COUNT} .avif file(s). Converting to WebP with max width 1900px..."
    find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.avif' \) -print0 | while IFS= read -r -d '' f; do
        fname="$(basename "$f")"
        base="${fname%.*}"
        out="${OUT_DIR}/${base}.webp"
        log "Converting: $fname -> webp/${base}.webp"
        magick "$f" -resize '1900>' -define webp:method=6 -quality 85 -strip "$out"
    done
fi

# --- Process JPG/JPEG files ---
log "Searching for .jpg/.jpeg files in: $SCRIPT_DIR"
JPG_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) | wc -l | tr -d ' ')

if [ "$JPG_COUNT" != "0" ]; then
    log "Found ${JPG_COUNT} .jpg/.jpeg file(s). Converting to WebP with max width 1900px..."
    find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | while IFS= read -r -d '' f; do
        fname="$(basename "$f")"
        base="${fname%.*}"
        out="${OUT_DIR}/${base}.webp"
        log "Converting: $fname -> webp/${base}.webp"
        magick "$f" -resize '1900>' -define webp:method=6 -quality 85 -strip "$out"
    done
fi

# --- Process PNG files ---
log "Searching for .png files in: $SCRIPT_DIR"
PNG_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.png' \) | wc -l | tr -d ' ')

if [ "$PNG_COUNT" != "0" ]; then
    log "Found ${PNG_COUNT} .png file(s). Converting to WebP with max width 1900px..."
    find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.png' \) -print0 | while IFS= read -r -d '' f; do
        fname="$(basename "$f")"
        base="${fname%.*}"
        out="${OUT_DIR}/${base}.webp"
        log "Converting: $fname -> webp/${base}.webp"
        magick "$f" -resize '1900>' -define webp:method=6 -quality 85 -strip "$out"
    done
fi

# --- Process existing WebP files (resize and move) ---
log "Searching for .webp files in: $SCRIPT_DIR"
WEBP_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.webp' \) | wc -l | tr -d ' ')

if [ "$WEBP_COUNT" != "0" ]; then
    log "Found ${WEBP_COUNT} .webp file(s). Resizing and moving to webp folder..."
    find "$SCRIPT_DIR" -maxdepth 1 -type f \( -iname '*.webp' \) -print0 | while IFS= read -r -d '' f; do
        fname="$(basename "$f")"
        out="${OUT_DIR}/${fname}"
        log "Processing: $fname"
        magick "$f" -resize '1900>' -define webp:method=6 -quality 85 -strip "$out"
    done
fi

# --- Summary ---
TOTAL=$((AVIF_COUNT + JPG_COUNT + PNG_COUNT + WEBP_COUNT))
if [ "$TOTAL" = "0" ]; then
    log "No image files found. Nothing to do."
    exit 0
fi

log "Done. Processed ${TOTAL} image(s). Output saved to: $OUT_DIR"
open "$OUT_DIR" >/dev/null 2>&1 || true
