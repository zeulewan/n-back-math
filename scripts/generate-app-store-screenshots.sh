#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT/ios/App/App.xcodeproj"
SCHEME="App"
BUNDLE_ID="com.zeulewan.nbackmath"
OUT="$ROOT/fastlane/screenshots/en-US"
DERIVED_DATA="${DERIVED_DATA:-$ROOT/ios/build/screenshot-derived-data}"
IPHONE_DEVICE="${IPHONE_DEVICE:-iPhone 17 Pro Max}"
IPAD_DEVICE="${IPAD_DEVICE:-iPad Pro 13-inch (M5)}"

find_udid() {
  local device_name="$1"

  python3 - "$device_name" <<'PY'
import json
import subprocess
import sys

device_name = sys.argv[1]
device_family = "iPad" if "iPad" in device_name else "iPhone"
raw = subprocess.check_output([
    "xcrun",
    "simctl",
    "list",
    "devices",
    "available",
    "--json",
])
devices = json.loads(raw)["devices"]
matches = [
    device["udid"]
    for runtime_devices in devices.values()
    for device in runtime_devices
    if device.get("isAvailable") and device["name"] == device_name
]

if not matches:
    matches = [
        device["udid"]
        for runtime_devices in devices.values()
        for device in runtime_devices
        if device.get("isAvailable") and device_family in device["name"]
    ]

if matches:
    print(matches[-1])
PY
}

capture_device() {
  local device_name="$1"
  local output_name="$2"
  shift 2
  local launch_args=("$@")
  local udid

  udid="$(find_udid "$device_name")"
  if [[ -z "$udid" ]]; then
    echo "Could not find available simulator named '$device_name'." >&2
    exit 1
  fi

  xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl ui "$udid" appearance dark >/dev/null 2>&1 || true
  sleep 8
  xcrun simctl install "$udid" "$APP_PATH"
  xcrun simctl launch "$udid" "$BUNDLE_ID" "${launch_args[@]}" >/dev/null
  sleep 5
  xcrun simctl io "$udid" screenshot "$OUT/$output_name"
  xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
}

mkdir -p "$OUT"
rm -f "$OUT"/*.png

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/App.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Could not find built app at $APP_PATH." >&2
  exit 1
fi

capture_device "$IPHONE_DEVICE" "01_iphone.png" --app-store-screenshot
capture_device "$IPAD_DEVICE" "02_ipad.png" --app-store-screenshot
capture_device "$IPHONE_DEVICE" "03_iphone_stats.png" --app-store-screenshot --screenshot-tab=stats
capture_device "$IPAD_DEVICE" "04_ipad_stats.png" --app-store-screenshot --screenshot-tab=stats

echo "Wrote native App Store screenshots to $OUT"
