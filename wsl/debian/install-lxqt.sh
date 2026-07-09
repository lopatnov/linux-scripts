#!/bin/bash
# Установка LXQt на Debian 13 WSL. Как видно из пакетов - без дополнительного софта

sudo apt update
sudo apt install -y lxqt-core xrdp dbus-x11
echo "startlxqt" > ~/.xsession
sudo adduser xrdp ssl-cert