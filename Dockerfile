FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	sed -i "/deb http:\/\/deb.debian.org\/debian buster main/c\deb http:\/\/deb.debian.org\/debian buster main non-free" /etc/apt/sources.list && \
	apt-get update && \
    apt-get -y install --no-install-recommends krusader breeze-icon-theme kompare krename bzip2 lzma xz-utils  lhasa zip unzip arj unace rar unrar p7zip-full rpm konsole && \
	ln -s /usr/bin/arj /usr/bin/unarj && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	apt-get -y install --no-install-recommends fonts-takao && \
	echo "ko_KR.UTF-8 UTF-8" >> /etc/locale.gen && \ 
	echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "Krusader - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

COPY locales_krusader.tar /tmp/locales_krusader.tar
RUN tar -C / -xvf /tmp/locales_krusader.tar && \
	rm -rf /tmp/locales_krusader.tar

ENV DATA_DIR=/krusader
ENV CUSTOM_RES_W=1280
ENV CUSTOM_RES_H=768
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV X11VNC_PARAMS=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="krusader"
ENV USER_LOCALES="en_US.UTF-8 UTF-8"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R ${UID}:${GID} /mnt && \
	chmod -R 770 /mnt

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]