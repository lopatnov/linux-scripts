#!/bin/bash
# Установка LXQt с оконным менеджером Xfwm4 на Ubuntu 26.04 WSL

sudo apt update

# Системные компоненты графики, меню, иконок и утилит для корректного отображения типов файлов
sudo apt install -y lxqt-core xrdp dbus-x11 xorgxrdp lxmenu-data shared-mime-info desktop-file-utils

# Ставим сам оконный менеджер xfwm4 (в 26.04 темы уже включены в этот пакет)
sudo apt install -y xfwm4

# Набор иконок (Oxygen закроет проблему пустых белых значков на десктопе)
sudo apt install -y hicolor-icon-theme tango-icon-theme oxygen-icon-theme

# Родные приложения среды LXQt, файловый менеджер и конфигураторы
sudo apt install -y pcmanfm-qt qterminal featherpad lximage-qt lxqt-config lxqt-themes

# Перевешиваем порт XRDP на 3390
sudo sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini

# Настройка доступов сертификатов
sudo groupadd -f ssl-cert
sudo adduser xrdp ssl-cert

# Задаем запуск LXQt через шину DBus
echo "exec dbus-launch --exit-with-session startlxqt" > ~/.xsession

# Настройки переменных окружения графики
cat << 'EOF' > ~/.xsessionrc
export QT_SELECT=qt5
export XDG_CURRENT_DESKTOP=LXQt
export XDG_SESSION_TYPE=x11
EOF

# Создаем конфигурационный каталог LXQt
mkdir -p ~/.config/lxqt

# Прописываем xfwm4 в качестве основного менеджера окон для сессии LXQt
cat << 'EOF' > ~/.config/lxqt/session.conf
[General]
window_manager=xfwm4
EOF

# Жестко прописываем тему значков Oxygen в настройках внешнего вида LXQt
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

# КРИТИЧЕСКИЙ ФИКС ЗНАЧКОВ: Обновляем базы данных MIME и ярлыков от имени администратора
sudo update-mime-database /usr/share/mime
sudo update-desktop-database /usr/share/applications
update-desktop-database ~/.local/share/applications 2>/dev/null

# Перезапуск графического сервера
sudo /etc/init.d/xrdp restart
