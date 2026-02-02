#!/bin/bash
# KrabWidget DMG Creator
# Run this script to create a distributable DMG installer

set -e

APP_NAME="KrabWidget"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="$(pwd)/build"
DMG_DIR="$(pwd)/dist"

echo "🦀 Building ${APP_NAME}..."

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$DMG_DIR"

# Build the app
xcodebuild -project "${APP_NAME}.xcodeproj" \
    -scheme "${APP_NAME}" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    -destination "platform=macOS" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    build

# Find the built app
APP_PATH=$(find "$BUILD_DIR" -name "${APP_NAME}.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Could not find built app!"
    exit 1
fi

echo "✅ App built at: $APP_PATH"

# Create DMG staging area
STAGING="$BUILD_DIR/dmg-staging"
rm -rf "$STAGING"
mkdir -p "$STAGING"

# Copy app to staging
cp -R "$APP_PATH" "$STAGING/"

# Create Applications symlink
ln -s /Applications "$STAGING/Applications"

# Create DMG
echo "📦 Creating DMG..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$STAGING" \
    -ov -format UDZO \
    "$DMG_DIR/${DMG_NAME}.dmg"

echo ""
echo "🎉 DMG created successfully!"
echo "📍 Location: $DMG_DIR/${DMG_NAME}.dmg"
echo ""
echo "To install:"
echo "1. Open the DMG"
echo "2. Drag KrabWidget to Applications"
echo "3. Launch from Applications folder"
echo ""
echo "🦀 CLACK CLACK!"
