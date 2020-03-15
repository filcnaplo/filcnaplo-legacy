#!/bin/bash

if [ "$1" == "-h" ]; then
	echo "Usage: `basename $0` (--full)";
	exit 0;
fi

inputFile=$(realpath $0)
libDir=$(echo "$inputFile" | cut -f 1 -d '.')"/../lib"
dartfmt -w --fix "$libDir";

if [ "$2" == "--full" ]; then
	echo "[FULL MODE ON!]"
	flutter clean;
	adb shell pm uninstall hu.filcnaplo.ellenorzo;
fi

flutter build apk;
adb install -r build/app/outputs/apk/release/app-release.apk;
flutter logs;