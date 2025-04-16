# Переходим в директорию проекта
cd /root/rl-swarm/modal-login || { echo "Ошибка: директория не найдена"; exit 1; }

# Устанавливаем зависимости и запускаем
yarn up
yarn install
yarn build
yarn start
