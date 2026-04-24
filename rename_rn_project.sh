#!/bin/bash

# bash rename_rn_project.sh "Your New App Name" "com.yournewbundle.id"

# Configuration: exit on any command failure
set -e


# Validate input arguments
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "❌ Error: Missing parameters."
  echo "Usage: ./rename_rn_project.sh \"New App Name\" \"com.newbundle.identifier\""
  echo "Example: ./rename_rn_project.sh \"Venue Pass\" \"com.venuepass\""
  exit 1
fi

NEW_APP_NAME="$1"
NEW_BUNDLE_ID="$2"

echo ""
echo "=========================================================="
echo "🚀 Renaming App to:  \"$NEW_APP_NAME\""
echo "🚀 New Bundle ID:    \"$NEW_BUNDLE_ID\""
echo "=========================================================="
echo ""

# 1. Run react-native-rename to modify native files (Android & iOS settings)
echo "📦 Running react-native-rename..."
npx -y react-native-rename "$NEW_APP_NAME" -b "$NEW_BUNDLE_ID" --skipGitStatusCheck

echo ""
echo "=========================================================="
echo "🧹 Cleaning caches and reinstalling dependencies..."
echo "=========================================================="
echo ""

# 2. Invalidate Watchman caches to prevent ghost module collisions
echo "🔍 Clearing Watchman cache..."
watchman watch-del-all || echo "⚠️ Watchman not installed or not running, skipping..."

# 3. Ensure local Node modules are freshly built
echo "📦 Running yarn install..."
yarn install

# 4. Sync iOS Pods with the new environment identifiers
if [ -d "ios" ]; then
  echo "🍎 Syncing iOS CocoaPods..."
  if npx --no pod-install &> /dev/null; then
    npx pod-install
  else
    cd ios && pod install && cd ..
  fi
else
  echo "⚠️ 'ios' directory not found. Skipping CocoaPods sync."
fi

echo ""
echo "=========================================================="
echo "✅ App successfully renamed to \"$NEW_APP_NAME\" ($NEW_BUNDLE_ID)!"
echo "⚠️ IMPORTANT NEXT STEPS:"
echo " 1. Start Metro cleanly: 'yarn start --reset-cache'"
echo " 2. Perform a clean rebuild: 'cd android && ./gradlew clean' and/or clear your XCode Build Folder."
echo "=========================================================="
echo ""
