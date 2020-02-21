#!/usr/bin/env python3
import sys
from shutil import copyfile

ttyama0 = "pi3-miniuart-bt-overlay.dtb"
ft5406 = "rpi-ft5406-overlay.dtb"
cmdline = "{}/rpi-firmware/cmdline.txt".format(sys.argv[1])
config = "{}/rpi-firmware/config.txt".format(sys.argv[1])
copyfile("{}/{}".format(sys.argv[1], ft5406), "{}/rpi-firmware/overlays/{}".format(sys.argv[1], ft5406))
copyfile("{}/{}".format(sys.argv[1], ttyama0), "{}/rpi-firmware/overlays/{}".format(sys.argv[1], ttyama0))

with open(cmdline, 'r+') as f:
    content = f.readline().strip('\n')
    remove = "console=ttyAMA0,115200"

    if remove in content:
        content = content.replace(remove, '')

    correction = "quiet splash loglevel=0 console=tty3 vt.global_cursor_default=0"
    if not correction in content:
        content = content + " " + correction
    f.seek(0)
    f.truncate()
    f.write(content)

with open(config, 'r+') as f:
    content = f.readlines()
    dtoverlay = 'dtoverlay=pi3-miniuart-bt\n'
    nosplash = 'disable_splash=1\n'

    if not dtoverlay in content:
        f.write(dtoverlay)
    if not nosplash in content:
        f.write(nosplash)
