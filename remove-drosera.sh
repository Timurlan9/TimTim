#!/bin/bash

echo "[1/8] Остановка сервиса drosera..."
sudo systemctl stop drosera.service

echo "[2/8] Отключение автозапуска drosera..."
sudo systemctl disable drosera.service

echo "[3/8] Удаление systemd юнита drosera..."
sudo rm /etc/systemd/system/drosera.service

echo "[4/8] Перезагрузка systemd демона..."
sudo systemctl daemon-reload

echo "[5/8] Удаление директории ~/drosera..."
rm -rf ~/drosera

echo "[6/8] Удаление базы данных ~/.drosera.db..."
rm -rf ~/.drosera.db

echo "[7/8] Удаление директории ~/.drosera..."
rm -rf ~/.drosera

echo "[8/8] Удаление бинарника drosera-operator..."
rm -f ~/drosera-operator

echo "✅ Удаление drosera завершено."
