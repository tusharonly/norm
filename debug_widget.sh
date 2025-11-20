#!/bin/bash

# Widget Debugging Script for Norm App
# This script helps debug widget issues by checking logs and shared preferences

echo "=== Norm Widget Debugging Script ==="
echo ""

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ No Android device connected"
    echo "Please connect a device or start an emulator"
    exit 1
fi

echo "✅ Device connected"
echo ""

# Check if app is installed
if ! adb shell pm list packages | grep -q "com.tusharghige.norm"; then
    echo "❌ Norm app is not installed"
    echo "Please install the app first: flutter install"
    exit 1
fi

echo "✅ App is installed"
echo ""

# Check shared preferences
echo "📁 Checking shared preferences..."
echo "---"
adb shell "run-as com.tusharghige.norm cat /data/data/com.tusharghige.norm/shared_prefs/HomeWidgetPreferences.xml" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "⚠️  Could not read shared preferences"
    echo "This might mean:"
    echo "  1. App hasn't been opened yet"
    echo "  2. No habits have been created"
    echo "  3. Widget service hasn't saved data yet"
else
    echo "---"
fi

echo ""
echo "📱 Recent widget-related logs:"
echo "---"
adb logcat -d | grep -E "HabitWidget|WidgetService" | tail -30

echo ""
echo "---"
echo ""
echo "💡 Next steps:"
echo "1. Open the Norm app"
echo "2. Create or toggle a habit"
echo "3. Check if widget updates"
echo "4. Run this script again to see new logs"
echo ""
echo "To see live logs, run:"
echo "  adb logcat | grep -E 'HabitWidget|WidgetService'"
