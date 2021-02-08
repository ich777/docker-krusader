#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
    chmod +x /opt/scripts/user.sh
    /opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

if [ ! -d /tmp/xdg ]; then
	mkdir /tmp/xdg
fi

echo "---Configuring Locales to: ${USER_LOCALES}---"
LOCALE_GEN=$(head -n 1 /etc/locale.gen)
export LOCALE_USR=$(echo ${USER_LOCALES} | cut -d ' ' -f 1)

if [ "$LOCALE_GEN" != "${USER_LOCALES}" ]; then
	rm /etc/locale.gen
	echo -e "${USER_LOCALES}\nen_US.UTF-8 UTF-8" > "/etc/locale.gen"
	export LANGUAGE="$LOCALE_USR"
	export LANG="$LOCALE_USR"
	sleep 2
	locale-gen
	update-locale LC_ALL="$LOCALE_USR" >/dev/null
else
	echo "---Locales set correctly, continuing---"
fi

echo "---Checking configuration for noVNC---"
novnccheck

echo "---Starting...---"
chown -R ${UID}:${GID} /opt/scripts
chown -R ${UID}:${GID} /tmp/xdg
chown -R ${UID}:${GID} ${DATA_DIR}
chown ${UID}:${GID} /mnt
chmod -R 0700 /tmp/xdg
chmod ${DATA_PERM} /mnt

term_handler() {
	kill -SIGTERM "$killpid"
	wait "$killpid" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
if [ "${RUNASROOT}" == "true" ]; then
	if [ ! -d /root/.config ];then
		if [ -d ${DATA_DIR}/.config ]; then
			cp -r ${DATA_DIR}/.config /root/
			chown -R root:root /root/.config
			chmod -R 755 /root/.config
		fi
	fi
	if [ ! -d /root/.vnc ];then
		if [ -d ${DATA_DIR}/.vnc ]; then
			cp -r ${DATA_DIR}/.vnc /root/
			chown -R root:root /root/.vnc
			chmod -R 755 /root/.vnc
		fi
	fi
	/opt/scripts/start-server.sh &
else
	su ${USER} -c "/opt/scripts/start-server.sh" &
fi
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done