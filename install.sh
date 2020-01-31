#!/bin/bash
adb shell pm uninstall org.filc.naplo
adb install build/app/outputs/apk/release/app-release.apk
