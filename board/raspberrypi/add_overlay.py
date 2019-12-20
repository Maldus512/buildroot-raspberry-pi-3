#!/usr/bin/env python3
import sys
from shutil import copyfile

ft5406 = "rpi-ft5406-overlay.dtb"
cmdline = "{}/rpi-firmware/cmdline.txt".format(sys.argv[1])
copyfile("{}/{}".format(sys.argv[1], ft5406), "{}/rpi-firmware/overlays/{}".format(sys.argv[1], ft5406))

with open(cmdline, 'r+') as f:
    content = f.readline().strip('\n')
    if not "quiet splash vt.global_cursor_default=0" in content:
        f.truncate(0)
        f.write(content + " quiet splash vt.global_cursor_default=0")
