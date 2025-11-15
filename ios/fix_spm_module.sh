#!/bin/bash

# Script to fix "No such module 'StarIO10'" error in Flutter plugin
# This script cleans the build and provides instructions for adding SPM dependency

set -e

echo "=================================================="
echo "Star Micronics Printer - SPM Module Fix Script"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
EXAMPLE_DIR="$PROJECT_ROOT/example"
IOS_DIR="$EXAMPLE_DIR/ios"

echo "Detected paths:"
echo "  Plugin root: $PROJECT_ROOT"
echo "  Example app: $EXAMPLE_DIR"
echo "  iOS folder:  $IOS_DIR"
echo ""

# Step 1: Clean everything
echo -e "${YELLOW}Step 1: Cleaning build artifacts...${NC}"
cd "$PROJECT_ROOT"

echo "  - Running flutter clean..."
flutter clean

echo "  - Removing iOS build artifacts..."
cd "$IOS_DIR"
rm -rf Pods/ Podfile.lock .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/Star* 2>/dev/null || true

echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Step 2: Flutter pub get
echo -e "${YELLOW}Step 2: Getting Flutter dependencies...${NC}"
cd "$PROJECT_ROOT"
flutter pub get

cd "$EXAMPLE_DIR"
flutter pub get

echo -e "${GREEN}✓ Dependencies fetched${NC}"
echo ""

# Step 3: Pod install
echo -e "${YELLOW}Step 3: Installing CocoaPods...${NC}"
cd "$IOS_DIR"

if ! command -v pod &> /dev/null; then
    echo -e "${RED}ERROR: CocoaPods not found. Install with: sudo gem install cocoapods${NC}"
    exit 1
fi

pod install --repo-update

echo -e "${GREEN}✓ Pods installed${NC}"
echo ""

# Step 4: Instructions for Xcode
echo "=================================================="
echo -e "${YELLOW}IMPORTANT: Manual Step Required in Xcode${NC}"
echo "=================================================="
echo ""
echo "The build has been cleaned and CocoaPods installed."
echo "Now you MUST add StarIO10 via Xcode:"
echo ""
echo "1. Open the workspace:"
echo -e "   ${GREEN}open $IOS_DIR/Runner.xcworkspace${NC}"
echo ""
echo "2. In Xcode, add StarIO10 package:"
echo "   a. Select 'Runner' project in left sidebar"
echo "   b. Select 'Runner' TARGET (not project)"
echo "   c. Go to 'General' tab"
echo "   d. Scroll to 'Frameworks, Libraries, and Embedded Content'"
echo "   e. Click '+' button"
echo "   f. Click 'Add Other' → 'Add Package Dependency'"
echo "   g. Paste URL: https://github.com/star-micronics/StarXpand-SDK-iOS"
echo "   h. Click 'Add Package'"
echo "   i. Ensure 'StarIO10' is selected and click 'Add Package'"
echo ""
echo "3. ALSO add to plugin target:"
echo "   a. In project navigator, expand 'Pods' project"
echo "   b. Select 'star_micronics_printer' TARGET"
echo "   c. Go to 'Build Phases' tab"
echo "   d. Expand 'Link Binary With Libraries'"
echo "   e. If StarIO10.framework isn't there, click '+' and add it"
echo ""
echo "4. Build in Xcode (Cmd+B)"
echo ""
echo "5. If successful, return to terminal and run:"
echo -e "   ${GREEN}cd $EXAMPLE_DIR && flutter run${NC}"
echo ""
echo "=================================================="

# Offer to open Xcode
read -p "Would you like to open Xcode now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$IOS_DIR/Runner.xcworkspace"
    echo -e "${GREEN}Xcode opened. Follow the instructions above.${NC}"
else
    echo "You can open it manually with:"
    echo -e "${GREEN}open $IOS_DIR/Runner.xcworkspace${NC}"
fi

echo ""
echo "For more details, see: $SCRIPT_DIR/FIX_MODULE_ERROR.md"
