# Krusader in Docker optimized for Unraid
Krusader is an advanced orthodox file manager for KDE and other desktops in the Unix world. It is similar to the console-based GNU Midnight Commander, GNOME Commander for the GNOME desktop environment, or Total Commander for Windows, all of which can trace their paradigmatic features to the original Norton Commander for DOS. It supports extensive archive handling, mounted filesystem support, FTP, advanced search, viewer/editor, directory synchronisation, file content comparisons, batch renaming, etc.

**Language Notice:** Enter your prefered locales, you can find a full list of supported languages in: '/usr/share/i18n/SUPPORTED' simply open up a console from the Container and type in 'cat /usr/share/i18n/SUPPORTED' (eg: 'en_US.UTF-8 UTF8' or 'de_DE.UTF-8 UTF-8', 'fr_FR.UTF-8 UTF-8'...)


## Env params
| Name | Value | Example |
| --- | --- | --- |
| USER_LOCALES | Enter your prefered locales, you can find a full list of supported languages in: '/usr/share/i18n/SUPPORTED' simply open up a console from the Container and type in 'cat /usr/share/i18n/SUPPORTED' (eg: 'en_US.UTF-8 UTF8' or 'de_DE.UTF-8 UTF-8', 'fr_FR.UTF-8 UTF-8'...) | en_US.UTF-8 UTF8 |
| CUSTOM_RES_W | Minimum of 1024 pixesl (leave blank for 1024 pixels) | 1280 |
| CUSTOM_RES_H | Minimum of 768 pixesl (leave blank for 768 pixels) | 1024 |
| UMASK | Set permissions for newly created files | 000 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name Krusader -d \
    -p 8080:8080 \
    --env 'USER_LOCALES=en_US.UTF-8 UTF8' \
    --env 'CUSTOM_RES_W=1280' \
    --env 'CUSTOM_RES_H=1024' \
    --env 'UMASK=000' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/krusader:/krusader \
    --volume /mnt/user:/mnt/user \
    --restart=unless-stopped\
    ich777/krusader
```

### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true


This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/