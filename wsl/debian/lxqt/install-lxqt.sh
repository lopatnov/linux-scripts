#!/bin/bash
# Установка LXQt Core на Debian 13 WSL. Подключение через RDP.
# Скрипт объединяет базовую установку с оптимизациями для WSL (xfwm4, аудио, иконки).

set -e
export DEBIAN_FRONTEND=noninteractive

echo "--- Updating system ---"
sudo apt update

echo "--- Installing base components ---"
sudo apt install -y --no-install-recommends \
    lxqt-core \
    xrdp \
    xorgxrdp \
    dbus-x11 \
    ssl-cert \
    policykit-1 \
    lxmenu-data \
    shared-mime-info \
    desktop-file-utils

echo "--- Installing window manager and icons ---"
# xfwm4 работает стабильнее в WSL, чем стандартный openbox
sudo apt install -y xfwm4 hicolor-icon-theme tango-icon-theme oxygen-icon-theme

echo "--- Installing LXQt apps and Audio ---"
sudo apt install -y --no-install-recommends \
    pcmanfm-qt \
    qterminal \
    featherpad \
    lximage-qt \
    lxqt-config \
    lxqt-themes \
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    nano

echo "--- Configuring XRDP ---"
# Меняем стандартный порт 3389 на 3390, чтобы избежать конфликта с Windows
sudo sed -i 's/^port=3389/port=3390/' /etc/xrdp/xrdp.ini

# Добавляем права для корректной работы SSL и Аудио
sudo adduser xrdp ssl-cert || true

echo "--- Configuring Session ---"
# Запуск через dbus-launch обязателен для работы многих функций DE
cat << 'EOF' > ~/.xsession
#!/bin/sh
exec dbus-launch --exit-with-session startlxqt
EOF
chmod +x ~/.xsession

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

# Принудительно ставим тему значков Oxygen
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
sudo service xrdp restart || sudo /etc/init.d/xrdp restart

echo "Done! Connect via RDP to localhost:3390"
