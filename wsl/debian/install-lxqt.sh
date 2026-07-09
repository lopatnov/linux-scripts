#!/bin/bash
# Установка LXQt Core на Debian 13 WSL. Подключение через RDP.

sudo apt update
sudo apt install -y lxqt-core xrdp dbus-x11

# ХИТРЫЙ ШАГ: Меняем стандартный порт 3389 на 3390, чтобы избежать конфликта с Windows
sudo sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini

# Настраиваем запуск LXQt для текущего пользователя
echo "startlxqt" > ~/.xsession

# Добавляем права для корректной работы SSL в xrdp
sudo adduser xrdp ssl-cert
