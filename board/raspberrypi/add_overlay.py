#!/usr/bin/env python3
import sys
from shutil import copyfile

ttyama0 = "pi3-miniuart-bt-overlay.dtb"
ft5406 = "rpi-ft5406-overlay.dtb"
i2crtc = "i2c-rtc-overlay.dtb"

overlays = [ttyama0, ft5406, i2crtc]

cmdline = "{}/rpi-firmware/cmdline.txt".format(sys.argv[1])
config = "{}/rpi-firmware/config.txt".format(sys.argv[1])

for o in overlays:
    copyfile("{}/{}".format(sys.argv[1], o), "{}/rpi-firmware/overlays/{}".format(sys.argv[1], o))


with open(cmdline, 'r+') as f:
    content = f.readline().strip('\n')
    rs = ["console=ttyAMA0,115200", "console=tty1"]

    for remove in rs:
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
    uartoverlay = 'dtoverlay=pi3-miniuart-bt\n'
    rtcoverlay = 'dtoverlay=i2c-rtc,pcf8523\n'
    nosplash = 'disable_splash=1\n'
    dtparam = 'dtparam=i2c_arm=on\n'

    options = [uartoverlay, rtcoverlay, nosplash, dtparam, 'max_framebuffers=2\n', 'display_default_lcd=1\n', 'hdmi_force_hotplug=1\n']

    for option in options:
        if not option in content:
            f.write(option)
