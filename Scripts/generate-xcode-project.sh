#!/bin/bash

# Open Swift Package in Xcode
# This script ensures proper Xcode workflow for the Swift Package

set -e

echo "🚀 Opening Virtual Office Pomodoro in Xcode..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "${RED}❌ Error: Package.swift not found!${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

echo ""
echo "${YELLOW}⚠️  IMPORTANT:${NC}"
echo "Modern iOS development with Swift Package Manager uses Package.swift directly."
echo "Do NOT create a separate .xcodeproj file."
echo ""

echo "${BLUE}📦 Opening Package.swift in Xcode...${NC}"
open Package.swift

echo ""
echo "${GREEN}✅ Xcode should now open with the package!${NC}"
echo ""
echo "Next steps:"
echo "  1. ${BLUE}Wait${NC} for 'Fetching dependencies...' to complete (1-2 minutes)"
echo "  2. ${BLUE}Select${NC} the 'App' scheme from the scheme picker"
echo "  3. ${BLUE}Choose${NC} your simulator or device"
echo "  4. ${BLUE}Press${NC} ⌘R to build and run"
echo ""
echo "If you see 'No such module' errors:"
echo "  • File → Packages → Reset Package Caches"
echo "  • File → Packages → Update to Latest Package Versions"
echo "  • Clean Build Folder (⇧⌘K) and rebuild (⌘B)"
echo ""
echo "📖 For more help, see QUICKSTART.md"
echo ""
