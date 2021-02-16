#!/usr/bin/env sh
mount /dev/mmcblk0p3 /mnt/data

if [ ! -f "/mnt/data/extended" ]; then
    umount /dev/mmcblk0p3
    sh /root/resize_data.sh
    mount -o rw /dev/mmcblk0p3 /mnt/data
    touch /mnt/data/extended
    touch /mnt/data/toresize
    sync
    reboot
    exit 0
fi

if [ -f "/mnt/data/toresize" ]; then
    umount /dev/mmcblk0p3
    resize2fs /dev/mmcblk0p3

    mount -o rw /dev/mmcblk0p3 /mnt/data
    rm /mnt/data/toresize
    umount /dev/mmcblk0p3
fi

if [ -f "/root/newapp" ]; then
    # Esegui la nuova applicazione da tmp la prima volta
    # deve essere lei a copiarsi nel punto giusto se non ci sono problemi
    cp /root/newapp /tmp/newapp
    mount -o remount,rw /dev/mmcblk0p2 /
    rm /root/newapp
    mount -o remount,ro /dev/mmcblk0p2 /
    chmod u+x /tmp/newapp

    # Indica la destinazione dell'aggiornamento con il flag -u
    /tmp/newapp -u /root/app
fi

save_reports() {
    echo "`date`: L'applicazione e' terminata inaspettatamente" >> /tmp/WS2020_log.txt

    touch /tmp/appversion.txt
    mount -o remount,rw /dev/mmcblk0p3 /mnt/data
    mkdir -p /mnt/data/reports
    cp /root/version.txt /mnt/data/reports/osversion.txt
    tar -cf - -C /tmp/ WS2020_log.txt appversion.txt osversion.txt cores | gzip > /mnt/data/reports/"`date +%H_%M_%S-%d_%m_%Y`.tar.gz"
    rm /tmp/cores/*
    mount -o remount,ro /dev/mmcblk0p3 /mnt/data
}

clean_reports() {
    SIZE=`du /mnt/data/reports`
    SIZE="${SIZE//[!0-9]/}"

    if [ $SIZE -ge 100000 ]; then
        mount -o remount,rw /dev/mmcblk0p3 /mnt/data
        echo "Cleaning old reports to save storage space"
        find /mnt/data/reports -type f -mtime +30 -exec rm -f {} \;
        mount -o remount,ro /dev/mmcblk0p3 /mnt/data
    fi
}

ulimit -c unlimited

# write app version on disk (prints version then quits)
/root/app --version > /tmp/appversion.txt

CRASH=0

# -c flag signals a crash
while true; do
    if [ $CRASH -ne 0 ]; then
        # save report
        save_reports
        # delete old reports
        clean_reports 
        /root/app -c
    else
        /root/app 
    fi

    CRASH=$?
    echo $CRASH
    sleep 2
done;
