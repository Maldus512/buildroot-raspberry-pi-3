#!/usr/bin/env python
import sys
import os

try:
    password = os.environ['WIFI_PASSWORD']
except KeyError:
    print("WIFI_PASSWORD not set")
    exit(1)

with open("{}/etc/wpa_supplicant.conf".format(sys.argv[1]), 'r+') as f:
    content = f.read()
    f.seek(0)
    f.truncate()
    f.write(content.format(password))

print(sys.argv[0])
print("Added required environment variables")
