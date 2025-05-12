yarn add next@latest react react-dom &>/dev/null
    yarn add viem@latest &>/dev/null
    yarn dev > /dev/null 2>&1 & # Run in background and suppress output
    echo "Установка завершена"
    echo "-----------------------------------------------------------------------------"
    echo ""

    echo "Please login to create an Ethereum Server Wallet"
    SERVER_PID=$!  # Store the process ID
    sleep 5
    #open http://localhost:3000
    cd ..

    # Wait until modal-login/temp-data/userData.json exists
    while [ ! -f "modal-login/temp-data/userData.json" ]; do
        echo "Ждем авторизацию (localhost:3000)..."
        sleep 5  # Wait for 5 seconds before checking again
    done
    echo "Авторизировано. Продолжаем..."

    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' modal-login/temp-data/userData.json)
    echo "Your ORG_ID is set to: $ORG_ID"

    # Function to clean up the server process
    cleanup() {
        echo_green ">> Shutting down trainer..."
        kill $SERVER_PID
        rm -r modal-login/temp-data/*.json
        exit 0
    }

    # Set up trap to catch Ctrl+C and call cleanup
    #trap cleanup EXIT

    echo "Ждем активацию API ключа..."
    while true; do
        STATUS=$(curl -s "http://localhost:3000/api/get-api-key-status?orgId=$ORG_ID")
        if [[ "$STATUS" == "activated" ]]; then
            echo "API ключ активирован! Продолжаем..."
            break
        else
            echo "Ждем активацию API ключа..."
            sleep 5
        fi
    done
    ENV_FILE="$ROOT"/modal-login/.env
    sed -i "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"

if [[ -f "/root/$PEM_FILE" ]]; then
    echo "Нашли бекап файла $PEM_FILE в /root/. Копирую в папку проекта $ROOT..."
    cp "/root/$PEM_FILE" "$ROOT/"
fi

#lets go!
echo "Ставим python dependencies (5-15 мин)..."
pip install --upgrade pip &>/dev/null

if [ -n "$CPU_ONLY" ] || ! command -v nvidia-smi &> /dev/null; then
    # CPU-only mode or no NVIDIA GPU found
    pip install -r "$ROOT"/requirements-cpu.txt &>/dev/null
    #pip install hf_xet &>/dev/null
    CONFIG_PATH="$ROOT/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml" # TODO: Fix naming.
    GAME="gsm8k"
else
    # NVIDIA GPU found
    pip install -r "$ROOT"/requirements-gpu.txt &>/dev/null
    pip install flash-attn --no-build-isolation &>/dev/null

    case "$PARAM_B" in
        32 | 72) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-bnb-4bit-deepseek-r1.yaml" && break ;;
        0.5 | 1.5 | 7) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-deepseek-r1.yaml" && break ;;
        *)  echo ">>> Please answer in [0.5, 1.5, 7, 32, 72]." ;;
    esac
    if [ "$USE_BIG_SWARM" = true ]; then
        GAME="dapo"
    else
        GAME="gsm8k"
    fi
fi

echo ">> Готово!"
echo ""
echo ""

if [ -n "${HF_TOKEN}" ]; then # Check if HF_TOKEN is already set and use if so. Else give user a prompt to choose.
   HUGGINGFACE_ACCESS_TOKEN=${HF_TOKEN}
else
   read -p "Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N] " yn
   yn=${yn:-N}  # Default to "N" if the user presses Enter
   case $yn in
      [Yy]* ) read -p "Enter your Hugging Face access token: " HUGGINGFACE_ACCESS_TOKEN;;
      [Nn]* ) HUGGINGFACE_ACCESS_TOKEN="None";;
      * ) echo ">>> No answer was given, so NO models will be pushed to Hugging Face Hub" && HUGGINGFACE_ACCESS_TOKEN="None";;
   esac
fi

echo ""
echo ""
echo_green "Good luck in the swarm!"
# end official script part

# делаем скрипт для будущего systemd сервиса
OUTPUT_SCRIPT="$ROOT/gensyn_service.sh"

if [ -n "$ORG_ID" ]; then
cat <<EOF > "$OUTPUT_SCRIPT"
#!/bin/bash

# Set working directory
FOLDER="$ROOT"
cd "\$FOLDER" || exit 1

source /root/.profile
source .venv/bin/activate

pkill next-server

cd modal-login
yarn install
yarn dev > /dev/null 2>&1 &
cd ..

# Set parameters
HUGGINGFACE_ACCESS_TOKEN="$HUGGINGFACE_ACCESS_TOKEN"
IDENTITY_PATH="$IDENTITY_PATH"
ORG_ID="$ORG_ID"
CONFIG_PATH="$CONFIG_PATH"
SWARM_CONTRACT="$SWARM_CONTRACT"
GAME="$GAME"

    python -m hivemind_exp.gsm8k.train_single_gpu \
        --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
        --identity_path "$IDENTITY_PATH" \
        --modal_org_id "$ORG_ID" \
        --contract_address "$SWARM_CONTRACT" \
        --config "$CONFIG_PATH" \
        --game "$GAME"

wait
EOF
else
cat <<EOF > "$OUTPUT_SCRIPT"
#!/bin/bash

# Set working directory
FOLDER="$ROOT"
cd "\$FOLDER" || exit 1

source /root/.profile
source .venv/bin/activate

pkill next-server


# Set parameters
HUGGINGFACE_ACCESS_TOKEN="$HUGGINGFACE_ACCESS_TOKEN"
IDENTITY_PATH="$IDENTITY_PATH"
CONFIG_PATH="$CONFIG_PATH"
PUB_MULTI_ADDRS="$PUB_MULTI_ADDRS"
PEER_MULTI_ADDRS="$PEER_MULTI_ADDRS"
HOST_MULTI_ADDRS="$HOST_MULTI_ADDRS"
GAME="$GAME"

    python -m hivemind_exp.gsm8k.train_single_gpu \
        --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
        --identity_path "$IDENTITY_PATH" \
        --public_maddr "$PUB_MULTI_ADDRS" \
        --initial_peers "$PEER_MULTI_ADDRS" \
        --host_maddr "$HOST_MULTI_ADDRS" \
        --config "$CONFIG_PATH" \
        --game "$GAME"

wait
EOF
fi
chmod +x "$OUTPUT_SCRIPT"
echo "Скрипт для systemd сервиса создан: $OUTPUT_SCRIPT"

# создаем сам сервис в системе
SERVICE_NAME="gensyn.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
LOG_FILE="/var/log/gensyn.log"
ERROR_LOG_FILE="/var/log/gensyn_error.log"

# удаляем сервис если уже стоит
if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm "$SERVICE_FILE"
    fi
    > "$ERROR_LOG_FILE"
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi


# Create the systemd service file
cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Gensyn Service
After=network.target

[Service]
User=root
WorkingDirectory=$ROOT
ExecStart=/bin/bash $ROOT/gensyn_service.sh
Restart=always
RestartSec=5
StandardOutput=append:$LOG_FILE
StandardError=append:$ERROR_LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable gensyn.service
sudo systemctl start gensyn.service

sleep 10
cp "$ROOT/modal-login/temp-data/userApiKey.json" "$ROOT/userApiKey_backup.json"
cp "$ROOT/modal-login/temp-data/userData.json" "$ROOT/userData_backup.json"

echo "systemd сервис создан и запущен."
echo "Смотреть логи можно командой: tail -n 20 -f $ERROR_LOG_FILE"
