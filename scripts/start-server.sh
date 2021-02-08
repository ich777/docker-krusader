#!/bin/bash
export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp/xdg
export LANGUAGE="$LOCALE_USR"
export LANG="$LOCALE_USR"

echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1
screen -wipe 2&>/dev/null

echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=1024
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=768
fi

if [ "${CUSTOM_RES_W}" -le 1023 ]; then
	echo "---Width to low must be a minimal of 1024 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1024
fi
if [ "${CUSTOM_RES_H}" -le 767 ]; then
	echo "---Height to low must be a minimal of 768 pixels, correcting to 768...---"
    CUSTOM_RES_H=768
fi

chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting Xvfb server---"
screen -S Xvfb -L -Logfile ${DATA_DIR}/XvfbLog.0 -d -m /opt/scripts/start-Xvfb.sh
sleep 2
echo "---Starting x11vnc server---"
screen -S x11vnc -L -Logfile ${DATA_DIR}/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Krusader---"
echo
echo "+--------------------------------------------------------------------------------"
echo "|"
echo "| You are running Krusader as root, please be very carefull what you are doing!!!"
echo "|"
echo "+--------------------------------------------------------------------------------"
echo
cd ${DATA_DIR}
if [ "${RUNASROOT}" == "true" ]; then
	if [ "${DEV}" == "true" ]; then
		if [ ! -d /root/.config ]; then
			/usr/bin/krusader --left /mnt --right /mnt ${START_PARAMS}
		else
			/usr/bin/krusader ${START_PARAMS}
		fi
	else
		if [ ! -d /root/.config ]; then
			/usr/bin/krusader --left /mnt --right /mnt ${START_PARAMS} 2> /dev/null
		else
			/usr/bin/krusader ${START_PARAMS} 2> /dev/null
		fi
	fi
else
	if [ "${DEV}" == "true" ]; then
		if [ ! -d ${DATA_DIR}/.config ]; then
			/usr/bin/krusader --left /mnt --right /mnt ${START_PARAMS}
		else
			/usr/bin/krusader ${START_PARAMS}
		fi
	else
		if [ ! -d ${DATA_DIR}/.config ]; then
			/usr/bin/krusader --left /mnt --right /mnt ${START_PARAMS} 2> /dev/null
		else
			/usr/bin/krusader ${START_PARAMS} 2> /dev/null
		fi
	fi
fi