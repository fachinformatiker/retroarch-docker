#!/bin/bash
set -e 

RESOLUTION=${RESOLUTION:-1024x768x24}
LOG_LEVEL=${LOG_LEVEL:-INFO}
echo "Starting sunshine with RESOLUTION=${RESOLUTION} and LOG_LEVEL=${LOG_LEVEL}"

# Copying config in case it's the first time we mount from the host
mkdir -p /retroarch/
cp -u /retroarch.cfg /retroarch/retroarch.cfg
chown -R ${UNAME}:${UNAME} /retroarch/
chown -R ${UNAME}:${UNAME} /sunshine/
chown -R ${UNAME}:${UNAME} /dev/uinput
chown -R ${UNAME}:${UNAME} /usr/lib/x86_64-linux-gnu/dri/

_kill_procs() {
  kill -TERM $sunshine
  wait $sunshine
  kill -TERM $pulse
  wait $pulse
  kill -TERM $xorg
  wait $xorg
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

# Start Xorg
Xorg -noreset +extension GLX +extension RANDR +extension RENDER vt1 ${DISPLAY} &
xorg=$!

# Start pulseaudio
runuser -u ${UNAME} -- pulseaudio &
pulse=$!

# Start Sunshine
runuser -u ${UNAME} -- /sunshine/sunshine min_log_level=$LOG_LEVEL /sunshine/sunshine.conf
sunshine=$!

wait $sunshine
wait $xorg
wait $pulse