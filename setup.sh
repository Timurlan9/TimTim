set -e  # Остановить выполнение при ошибке

cd /root/rl-swarm/modal-login

echo "🧩 Установка зависимостей..."
corepack yarn install
yarn add lit-html
yarn add @wagmi/core
yarn build

yarn add eventemitter3
yarn add zod
yarn build

yarn add @aa-sdk/core
yarn add @walletconnect/modal-ui
yarn build

yarn add @tanstack/query-core
yarn add encoding
yarn build

yarn add pino-pretty

echo "✅ Зависимости установлены. Финальная сборка..."
yarn build
corepack yarn start
echo "🎉 Скрипт завершён успешно!"
