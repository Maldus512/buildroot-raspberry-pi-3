#!/usr/bin/env sh
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "default" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/mmcblk0
  d # delete partition...
  3 # ...3
  n # new partition
  p # primary partition
  3 # partition number 3
    # default - start at beginning of disk 
    # default - until the very end of the disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF
