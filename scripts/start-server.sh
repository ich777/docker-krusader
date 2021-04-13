#!/bin/bash
export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp/xdg
export LANGUAGE="$LOCALE_USR"
export LANG="$LOCALE_USR"
export XAUTHORITY=${DATA_DIR}/.Xauthority

echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
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

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Krusader---"
cd ${DATA_DIR}
if [ "${RUNASROOT}" == "true" ]; then
	echo
	echo "+--------------------------------------------------------------------------------"
	echo "|"
	echo "| You are running Krusader as root, please be very carefull what you are doing!!!"
	echo "|"
	echo "+--------------------------------------------------------------------------------"
	echo
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