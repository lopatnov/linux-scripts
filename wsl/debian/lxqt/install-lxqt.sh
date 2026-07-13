#!/bin/bash
# Установка LXQt Core на Debian 13 WSL. Подключение через RDP.
set -e

echo "--- Updating system ---"
sudo apt update

echo "--- Installing base components ---"
sudo apt install -y lxqt-core xrdp dbus-x11 xorgxrdp lxmenu-data shared-mime-info desktop-file-utils ssl-cert

echo "--- Installing window manager and icons ---"
sudo apt install -y xfwm4 hicolor-icon-theme tango-icon-theme oxygen-icon-theme

echo "--- Installing LXQt apps and themes ---"
sudo apt install -y pcmanfm-qt qterminal featherpad lximage-qt lxqt-config lxqt-themes

echo "--- Configuring XRDP ---"
# Меняем стандартный порт 3389 на 3390, чтобы избежать конфликта с Windows
sudo sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini

# Добавляем права для корректной работы SSL в xrdp
sudo adduser xrdp ssl-cert

echo "--- Configuring Session ---"
# Запуск через dbus-launch обязателен для работы многих функций DE
echo "exec dbus-launch --exit-with-session startlxqt" > ~/.xsession

# Переменные окружения для корректного определения среды
cat << 'EOF' > ~/.xsessionrc
export XDG_CURRENT_DESKTOP=LXQt
export XDG_SESSION_TYPE=x11
EOF

echo "--- Configuring LXQt Defaults ---"
mkdir -p ~/.config/lxqt

# Устанавливаем xfwm4 как оконный менеджер
cat << 'EOF' > ~/.config/lxqt/session.conf
[General]
window_manager=xfwm4
EOF

# Принудительно ставим тему значков
cat << 'EOF' > ~/.config/lxqt/lxqt.conf
[General]
icon_theme=oxygen
EOF

# Нативный автозапуск отрисовки значков рабочего стола через pcmanfm-qt
mkdir -p ~/.config/autostart
cat << 'EOF' > ~/.config/autostart/desktop.desktop
[Desktop Entry]
Type=Application
Name=LXQt Desktop
Exec=pcmanfm-qt --desktop
NoDisplay=true
EOF

echo "--- Updating Databases ---"
sudo update-mime-database /usr/share/mime
sudo update-desktop-database /usr/share/applications

echo "--- Restarting services ---"
sudo service xrdp restart

echo "Done! Connect via RDP to localhost:3390"
