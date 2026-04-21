#!/bin/bash

# HR Management System - Setup Checklist Script
# Run this to verify your setup is complete

echo "🔍 HR Management System - Setup Verification"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

# Check Flutter
echo "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found${NC}"
    errors=$((errors + 1))
else
    flutter_version=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓ Flutter installed: $flutter_version${NC}"
fi

# Check Dart
echo "Checking Dart installation..."
if ! command -v dart &> /dev/null; then
    echo -e "${RED}✗ Dart not found${NC}"
    errors=$((errors + 1))
else
    dart_version=$(dart --version 2>&1)
    echo -e "${GREEN}✓ Dart installed: $dart_version${NC}"
fi

# Check Git
echo "Checking Git installation..."
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git not found${NC}"
    errors=$((errors + 1))
else
    git_version=$(git --version)
    echo -e "${GREEN}✓ Git installed: $git_version${NC}"
fi

echo ""
echo "Checking project structure..."

# Check key directories
dirs=(
    "lib/config"
    "lib/core"
    "lib/data"
    "lib/domain"
    "lib/features"
    "assets"
    "android"
)

for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ Directory exists: $dir${NC}"
    else
        echo -e "${RED}✗ Directory missing: $dir${NC}"
        errors=$((errors + 1))
    fi
done

echo ""
echo "Checking key files..."

# Check key files
files=(
    "pubspec.yaml"
    "lib/main.dart"
    "lib/config/environment.dart"
    "lib/core/theme/app_theme.dart"
    "lib/core/enums/enums.dart"
    ".env.example"
    "README.md"
    "ARCHITECTURE.md"
    "DATABASE.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ File exists: $file${NC}"
    else
        echo -e "${RED}✗ File missing: $file${NC}"
        errors=$((errors + 1))
    fi
done

echo ""
echo "Checking feature modules..."

# Check feature directories
features=(
    "lib/features/auth"
    "lib/features/dashboard"
    "lib/features/employee"
    "lib/features/attendance"
    "lib/features/leave"
    "lib/features/payroll"
    "lib/features/reports"
    "lib/features/notifications"
    "lib/features/profile"
)

for feature in "${features[@]}"; do
    if [ -d "$feature" ]; then
        echo -e "${GREEN}✓ Feature module exists: $feature${NC}"
    else
        echo -e "${RED}✗ Feature module missing: $feature${NC}"
        errors=$((errors + 1))
    fi
done

# Check if environment.dart is configured
echo ""
echo "Checking configuration..."

if grep -q "YOUR_SUPABASE_URL" lib/config/environment.dart; then
    echo -e "${YELLOW}⚠ Supabase URL not configured${NC}"
    warnings=$((warnings + 1))
else
    echo -e "${GREEN}✓ Supabase URL configured${NC}"
fi

if grep -q "YOUR_SUPABASE_ANON_KEY" lib/config/environment.dart; then
    echo -e "${YELLOW}⚠ Supabase Anon Key not configured${NC}"
    warnings=$((warnings + 1))
else
    echo -e "${GREEN}✓ Supabase Anon Key configured${NC}"
fi

# Summary
echo ""
echo "=============================================="
echo "Setup Verification Summary"
echo "=============================================="

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
else
    echo -e "${RED}✗ $errors error(s) found${NC}"
fi

if [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}⚠ $warnings warning(s) found${NC}"
fi

echo ""
echo "Next steps:"
echo "1. Update Supabase credentials in lib/config/environment.dart"
echo "2. Run: flutter pub get"
echo "3. Create database schema (see DATABASE.md)"
echo "4. Run: flutter run"
echo ""
echo "For more information:"
echo "- QUICKSTART.md - 5-minute setup"
echo "- DEVELOPMENT_SETUP.md - Detailed guide"
echo "- ARCHITECTURE.md - Architecture details"
echo "- DATABASE.md - Database schema"
echo ""

if [ $errors -eq 0 ]; then
    exit 0
else
    exit 1
fi
