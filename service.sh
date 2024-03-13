#!/system/bin/sh

# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi

# Function that disables all the modules
disable_modules(){
    list="$("$busybox_path" find /data/adb/modules/* -prune -type d)"
    for module in $list; do
        touch "$module/disable"
    done
    reboot
    exit
}

# Check SystemUI process ID at three intervals
sleep 20
SYSTEMUI_PID1=$("$busybox_path" pgrep -f "systemui" | "$busybox_path" awk 'NR==1{print $1}')
sleep 15
SYSTEMUI_PID2=$("$busybox_path" pgrep -f "systemui" | "$busybox_path" awk 'NR==1{print $1}')
sleep 15
SYSTEMUI_PID3=$("$busybox_path" pgrep -f "systemui" | "$busybox_path" awk 'NR==1{print $1}')

# Compare the results  
if [ -n "$SYSTEMUI_PID1" ] && [ -n "$SYSTEMUI_PID2" ] && [ -n "$SYSTEMUI_PID3" ]; then
    if [ "$SYSTEMUI_PID1" != "$SYSTEMUI_PID2" ] || [ "$SYSTEMUI_PID2" != "$SYSTEMUI_PID3" ]; then
        disable_modules
    fi
fi