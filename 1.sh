name: Deploy RL-Swarm Modal Login

on:
  push:
    branches: [ main ]  # Запускать при пуше в main
  workflow_dispatch:    # Разрешить ручной запуск

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'  # Или ваша версия Node.js

    - name: Install Yarn
      run: npm install -g yarn

    - name: Run deployment commands
      run: |
        cd /root/rl-swarm/modal-login
        yarn up
        yarn install
        yarn build
        yarn start
