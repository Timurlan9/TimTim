set -e

echo "🔁 Перезапуск systemd сервиса gensyn.service..."
sudo systemctl restart gensyn.service

echo "🔁 Перезапуск Docker-контейнера brinxai_worker-worker-1..."
docker restart brinxai_worker-worker-1

echo "🔁 Перезапуск docker-compose стека из infernet-container-starter..."
docker compose -f "$HOME/infernet-container-starter/deploy/docker-compose.yaml" restart

echo "🔍 Запуск  скрипта от DOUBLE-TOP..."
tmux kill-session -t risc_service 2>/dev/null; cd /root/light-node/risc0-merkle-service && tmux new-session -d -s risc_service "cargo build && cargo run"
cd

echo "🔍 Запуск healthcheck скрипта от DOUBLE-TOP..."
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/multiple/healthcheck.sh)

echo "✅ Все задачи успешно выполнены."
