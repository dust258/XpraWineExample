FROM ubuntu:jammy

RUN dpkg --add-architecture i386

# Suppress an apt-key warning about standard out not being a terminal. Use in this script is safe.
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y tzdata fonts-roboto wget winbind xvfb unzip software-properties-common language-pack-de language-pack-gnome-de gnupg x11-xserver-utils python3-pip \ 
    && pip3 install pyinotify \
    && wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && wget -qO - https://xpra.org/gpg.asc | apt-key add - \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main' \
    && add-apt-repository 'deb [arch=amd64] https://xpra.org/ jammy main' \
    && apt-get update \
    && apt-get install -y --install-recommends wine-stable-i386=8.0.2~jammy-1 \
    && apt-get install -y --install-recommends wine-stable-amd64=8.0.2~jammy-1 \
    && apt-get install -y --install-recommends wine-stable=8.0.2~jammy-1 \
    && apt-get install -y --install-recommends winehq-stable=8.0.2~jammy-1 \
    && apt-get install -y xpra-common=6.1-r0-1 \
    && apt-get install -y xpra-client=6.1-r0-1 \
    && apt-get install -y xpra-client-gtk3=6.1-r0-1 \
    && apt-get install -y xpra-server=6.1-r0-1 \
    && apt-get install -y xpra-codecs=6.1-r0-1 \
    && apt-get install -y xpra-x11=6.1-r0-1 \
    && apt-get install -y xpra=6.1-r0-1 \
    && apt-get remove -y python3-pip avahi-daemon openssh-client \
    && apt-get autoremove -y \ 
    && mkdir -p /run/user/0/xpra \
    && rm -rf /var/lib/apt/lists/*`` \
    && wget -qcO - https://github.com/Xpra-org/xpra-html5/archive/refs/tags/v14.0.zip > xpra-html5-14.0.zip \
    && unzip xpra-html5-14.0.zip xpra-html5-14.0/html5/** \
    && rm -rv /usr/share/xpra/www/** \
    && mv /xpra-html5-14.0/html5/** /usr/share/xpra/www/ \
    && rm -rf /usr/share/backgrounds/ \
    && rm -rf /usr/share/xpra/www/*.br /usr/share/xpra/www/*.gz /usr/share/xpra/www/*/*.br /usr/share/xpra/www/*/*.gz

# Language and timezone
RUN localedef -i de_DE -f UTF-8 de_DE.UTF-8 \
    && echo "LANG=\"de_DE.UTF-8\"" > /etc/locale.conf \
    && ln -s -f /usr/share/zoneinfo/CET /etc/localtime
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8

# Create a non admin user
RUN useradd -ms /bin/bash wineuser
RUN usermod -a -G lpadmin wineuser

WORKDIR /home/wineuser

COPY ./run/run_gui.sh ./.run_gui.sh

RUN mkdir -m 777 -p /tmp/xdg/xpra \
    && rm -rvf /usr/share/applications/*.desktop 

COPY ./xpra/xpra.conf /etc/xpra/conf.d/xpra.conf
COPY ./xpra/client/ /usr/share/xpra/www/

RUN mkdir -m 777 -p "/run/user/$UID" \
    && chown -R wineuser:wineuser "/run/user/$UID" \
    && mkdir -m 700 -p "/run/user/$UID/xpra" \
    && chown -R wineuser:wineuser "/run/user/$UID/xpra" \
    && mkdir -m 775 -p "/run/xpra" \
    && chown -R wineuser:wineuser "/run/xpra" \
    && mkdir -m 777 -p "/home/wineuser/Downloads" \
    && chown -R wineuser:wineuser "/run/user/$UID" \
    && mkdir -m 777 -p "/run/user/$UID/xpra/0" \
    && chown -R wineuser:wineuser "/run/user/$UID/xpra/0" \
    && mkdir -m 777 -p "/run/user/$UID/xpra/0/socket" \
    && chown -R wineuser:wineuser "/run/user/$UID/xpra/0/socket" \
    && mkdir -m 777 -p "/run/user/$UID/xpra/0/pulse/pulse/native" \
    && chown -R wineuser:wineuser "/run/user/$UID/xpra/0/pulse/pulse/native" \
    && mkdir -m 777 -p "/run/dbus/system_bus_socket" \
    && chown -R wineuser:wineuser "/run/dbus/system_bus_socket" 


EXPOSE 8085

USER wineuser

CMD ["/bin/bash", "./.run_gui.sh"]
