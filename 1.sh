#!/bin/bash

set -e  # Остановить скрипт при любой ошибке
set -o pipefail

# Путь к директории
PROJECT_DIR="/root/rl-swarm/modal-login"

# Перейти в нужную директорию
cd "$PROJECT_DIR" || { echo "❌ Не удалось перейти в $PROJECT_DIR"; exit 1; }

echo "✅ Перешли в $PROJECT_DIR"

# Обновить зависимости
echo "🔄 Обновляем зависимости (yarn up)"
yarn up

# Установить зависимости
echo "📦 Установка зависимостей (yarn install)"
yarn install

# Собрать проект
echo "⚙️ Сборка проекта (yarn build)"
yarn build

# Запустить проект
echo "🚀 Запуск проекта (yarn start)"
yarn start
