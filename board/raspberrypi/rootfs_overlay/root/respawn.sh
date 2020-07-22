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

    # Indica la destinazione dell'aggiornamento con il flag -i
    /tmp/newapp -u /root/app
fi

save_reports() {
    echo "`date`: L'applicazione e' terminata inaspettatamente" >> /tmp/WS2020_log.txt

    mount -o remount,rw /dev/mmcblk0p3 /mnt/data
    mkdir -p /mnt/data/oldreports
    tar -cf - -C /tmp/ WS2020_log.txt cores | gzip > /mnt/data/oldreports/"`date +%H_%M_%S-%d_%m_%Y`.tar.gz"
    rm /tmp/cores/*
    mount -o remount,ro /dev/mmcblk0p3 /mnt/data
}

ulimit -c unlimited

# first execution, without signaling problems
/root/app
save_reports
sleep 2

# -c flag signals a crash
until /root/app -c; do
    save_reports
    sleep 2
done;
