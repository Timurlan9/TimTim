#!/bin/bash

echo "📁 Проверка прав доступа к drosera"
ls -la /root/.drosera/bin/drosera

echo "🔧 Делаем drosera исполняемым..."
chmod +x /root/.drosera/bin/drosera

echo "📁 Повторная проверка..."
ls -la /root/.drosera/bin/drosera

echo "🗑️ Удаляем drosera-operator из /usr/bin"
sudo rm -f /usr/bin/drosera-operator

echo "🔧 Делаем drosera-operator исполняемым..."
chmod +x /usr/bin/drosera-operator

echo "✅ Скрипт выполнен."
