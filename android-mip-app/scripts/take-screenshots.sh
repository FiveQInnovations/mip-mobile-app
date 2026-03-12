#!/bin/bash
# Capture screenshots of each main tab in the FFCI Android app.
# Skips tabs that open a browser (e.g. Give).
#
# Usage: ./scripts/take-screenshots.sh [output-dir]
# Default output dir: /tmp/ffci-screenshots

set -e

APP_ID="com.fiveq.ffci"
MAIN_ACTIVITY="$APP_ID/.MainActivity"
OUTPUT_DIR="${1:-/tmp/ffci-screenshots}"

# Tabs to screenshot: label, tap-x, tap-y
# Coordinates are centers of each nav item at 1080x2400 resolution (5 tabs).
# If tabs change, re-run: adb shell uiautomator dump && adb shell cat /sdcard/window_dump.xml
TABS=(
  "01-home:100:2232"
  "02-resources:320:2232"
  "03-media:540:2232"
  "04-connect:760:2232"
)

# ---------------------------------------------------------------------------

echo "Checking emulator..."
if ! adb devices | grep -q "emulator.*device"; then
  echo "Error: No Android emulator running."
  echo "  Start one with: emulator -avd Medium_Phone_API_36.0 &"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "Screenshots will be saved to: $OUTPUT_DIR"

echo ""
echo "Launching app..."
adb shell am force-stop "$APP_ID"
adb shell am start -n "$MAIN_ACTIVITY"

echo "Waiting for app to load..."
sleep 6

# Capture each tab
for entry in "${TABS[@]}"; do
  IFS=':' read -r name tap_x tap_y <<< "$entry"
  label="${name#*-}"   # strip leading number for display

  echo ""
  echo "Tapping $label tab..."
  adb shell input tap "$tap_x" "$tap_y"
  sleep 4  # wait for content to load

  outfile="$OUTPUT_DIR/${name}.png"
  adb exec-out screencap -p > "$outfile"
  echo "Saved: $outfile"
done

echo ""
echo "Done. $((${#TABS[@]})) screenshots saved to $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
