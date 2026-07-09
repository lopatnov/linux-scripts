#!/bin/bash
# Запуск LXQt в WSL

# Проверяем, запущен ли сервер xrdp в данный момент
if /etc/init.d/xrdp status >/dev/null 2>&1; then
    echo "Графика уже работает. Перезапускаю..."
    sudo /etc/init.d/xrdp restart
else
    echo "Графика отключена. Запускаю..."
    sudo /etc/init.d/xrdp start
fi

# Мгновенно запускаем RDP-клиент Windows прямо из Linux
echo "Открываю графический рабочий стол..."
mstsc.exe /v:localhost:3390