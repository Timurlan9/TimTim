echo "Оператор установлен. Создаем системный сервис"
ip_address=$(hostname -I | awk '{print $1}')

# удаляем сервис если уже стоит
if systemctl list-units --type=service --all | grep -q drosera.service; then
    sudo systemctl stop drosera.service
    sudo systemctl disable drosera.service
    if [ -f /etc/systemd/system/drosera.service ]; then
        sudo rm /etc/systemd/system/drosera.service
    fi
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi

sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=drosera node service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
    --eth-rpc-url $new_rpc \
    --eth-backup-rpc-url https://1rpc.io/holesky \
    --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 \
    --eth-private-key $privkey \
    --listen-address 0.0.0.0 \
    --network-external-p2p-address $ip_address \
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera
