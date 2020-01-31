#!/bin/bash
#flutter clean
flutter build apk
adb shell pm uninstall hu.filcnaplo.ellenorzo
adb install build/app/outputs/apk/release/app-release.apk
