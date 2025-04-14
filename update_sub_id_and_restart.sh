#!/bin/bash

CONFIG_PATH="$HOME/infernet-container-starter/deploy/config.json"
COMPOSE_FILE="$HOME/infernet-container-starter/deploy/docker-compose.yaml"

# Проверка наличия файла config.json
if [ ! -f "$CONFIG_PATH" ]; then
  echo "❌ Файл конфигурации не найден: $CONFIG_PATH"
  exit 1
fi

# Шаг 1: Заменить starting_sub_id
sed -i 's/"starting_sub_id": 160000/"starting_sub_id": 243300/' "$CONFIG_PATH"
echo "✅ starting_sub_id обновлён в $CONFIG_PATH"

# Шаг 2: Перезапуск контейнеров
docker compose -f "$COMPOSE_FILE" restart
echo "🔁 Контейнеры перезапущены."

# Шаг 3: Показать логи
echo "📜 Последние логи:"
docker compose -f "$COMPOSE_FILE" logs -f --tail=100
