#!/usr/bin/env python3
"""Adds android:screenOrientation="sensorLandscape" to MainActivity.

Run once after `flutter create --platforms=android .`. The app also locks
landscape at runtime (see lib/main.dart); this makes Android honour it from
the very first frame, before Flutter starts.
"""
import pathlib, sys

p = pathlib.Path("android/app/src/main/AndroidManifest.xml")
if not p.exists():
    sys.exit("AndroidManifest.xml not found - run `flutter create --platforms=android .` first")
s = p.read_text()
if "screenOrientation" in s:
    print("already set")
else:
    s = s.replace('<activity\n', '<activity\n            android:screenOrientation="sensorLandscape"\n', 1) \
        if '<activity\n' in s else s.replace('<activity ', '<activity android:screenOrientation="sensorLandscape" ', 1)
    p.write_text(s)
    print("landscape lock added")
