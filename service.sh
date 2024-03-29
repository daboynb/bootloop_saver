#!/system/bin/sh

#################################### functions
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
####################################

#################################### First check
# Check zygote process ID at three intervals
sleep 20
zygote_PID1=$("$busybox_path" pgrep -f "zygote" | "$busybox_path" awk 'NR==1{print $1}')
sleep 15
zygote_PID2=$("$busybox_path" pgrep -f "zygote" | "$busybox_path" awk 'NR==1{print $1}')
sleep 15
zygote_PID3=$("$busybox_path" pgrep -f "zygote" | "$busybox_path" awk 'NR==1{print $1}')

# Compare the results  
if [ -n "$zygote_PID1" ] && [ -n "$zygote_PID2" ] && [ -n "$zygote_PID3" ]; then
    if [ "$zygote_PID1" != "$zygote_PID2" ] || [ "$zygote_PID2" != "$zygote_PID3" ]; then
        disable_modules
    fi
fi
####################################

#################################### Second check
# Sleep for 10 seconds
sleep 10

# Check if boot completed
if [ "$(getprop sys.boot_completed)" = "1" ]; then
    echo "Boot process completed"
else
    echo "Boot process not completed."
    disable_modules
fi
####################################

#################################### Third check
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
#################################### End