#!/bin/bash

# Legal Assistant Pro - Vercel Build Script
# This script builds the Flutter web app with WASM support for production deployment

set -e  # Exit on error

echo "🚀 Building Legal Assistant Pro for Vercel deployment..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf web/build_output
flutter clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build web for release
echo "🔨 Building web for release..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Build failed. build/web directory not found."
    exit 1
fi

# Copy build output to web directory for Vercel
echo "📋 Copying build output to web directory..."
rm -rf web/build_output
cp -r build/web web/build_output

# Create a version file for cache busting
echo "$(date +%Y%m%d%H%M%S)" > web/build_version.txt

echo "✅ Build completed successfully!"
echo "📁 Build output available at: web/build_output/"
echo "🌐 Deploy with: vercel --prod"