#!/bin/bash

echo "=== Widget Data Sync Test ==="
echo ""
echo "This will show you what data the widget is receiving"
echo ""

# Clear old logs
adb logcat -c

echo "✅ Logs cleared"
echo ""
echo "Now:"
echo "1. Open the Norm app"
echo "2. Toggle a habit or create a new one"
echo "3. Wait 2 seconds"
echo ""
echo "Press Enter when ready to see the logs..."
read

echo ""
echo "=== Flutter Widget Service Logs ==="
adb logcat -d | grep "WidgetService" | tail -20

echo ""
echo "=== Android Widget Provider Logs ==="
adb logcat -d | grep "HabitWidgetProvider" | tail -10

echo ""
echo "=== Android Widget Data Logs ==="
adb logcat -d | grep "HabitWidget:" | tail -20

echo ""
echo "=== Shared Preferences Content ==="
adb shell "run-as com.tusharghige.norm cat /data/data/com.tusharghige.norm/shared_prefs/HomeWidgetPreferences.xml" 2>/dev/null || echo "Could not read shared preferences"

echo ""
echo "Done! Check the logs above to see:"
echo "- If Flutter is saving data (WidgetService logs)"
echo "- If Android is receiving update broadcast (HabitWidgetProvider logs)"
echo "- What data the widget is loading (HabitWidget logs)"
