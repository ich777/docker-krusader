#!/bin/bash
echo "---Ensuring UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Ensuring GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
cp -f /opt/custom/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:
cp -f /opt/scripts/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:

if [ -f /opt/scripts/start-user.sh ]; then
    echo "---Found optional script, executing---"
    chmod -f +x /opt/scripts/start-user.sh.sh ||:
    /opt/scripts/start-user.sh || echo "---Optional Script has thrown an Error---"
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

echo "---Taking ownership of data...---"
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} /tmp/xdg
chown -R ${UID}:${GID} ${DATA_DIR}
chown ${UID}:${GID} /mnt
chmod -R 0700 /tmp/xdg
chmod ${DATA_PERM} /mnt

echo "---Starting...---"
term_handler() {
	kill -SIGTERM $(pidof krusader)
	tail --pid=$(pidof krusader) -f 2>/dev/null
	sleep 0.5
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
	if [ -f ${DATA_DIR}/.vnc/passwd ];then
		cp -R ${DATA_DIR}/.vnc /root/
		chown -R root:root /root/.vnc
		chmod -R 755 /root/.vnc
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