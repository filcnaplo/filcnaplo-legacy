#!/bin/bash

if [ "$1" == "-h" ]; then
	echo "Usage: `basename $0` [--clean]";
	exit 0;
fi

inputFile=$(realpath $0)
libDir=$(echo "$inputFile" | cut -f 1 -d '.')"/../lib"

echo "Formatting code..."
dartfmt -w --fix "$libDir";

if [ "$2" == "--clean" ]; then
	echo "Cleaning up..."
	flutter clean;
	echo "Uninstalling old version..."
	adb shell pm uninstall hu.filcnaplo.ellenorzo;
fi

echo "Building app..."
flutter build apk;

echo "Installing app..."
adb install -r build/app/outputs/apk/release/app-release.apk;
flutter logs;