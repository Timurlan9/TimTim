#!/bin/bash

# Установка Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt install -y nodejs

# Настройка Yarn через Corepack
corepack enable
corepack prepare yarn@stable --activate

# Переход в директорию проекта и установка зависимостей
cd /root/rl-swarm/modal-login
yarn install

# Повторная активация Corepack (на всякий случай) и рестарт сервиса
corepack enable
sudo systemctl restart gensyn.service
