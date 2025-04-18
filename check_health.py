#!/usr/bin/env python3

# -*- coding: utf-8 -*-
import re
from pathlib import Path

LOG_PATH = "/var/log/gensyn_error.log"  # замените на путь к вашему логу

def parse_log(log_text):
    status = {
        "connected": False,
        "joined_swarm": False,
        "peer_id": None,
        "nickname": None,
        "training_started": False,
        "rounds_tracked": 0,
        "last_round": None,
        "warnings": [],
    }

    for line in log_text.splitlines():
        if "✅ Connected to Gensyn Testnet" in line:
            status["connected"] = True

        if "🐝 Joining swarm with initial_peers" in line:
            status["joined_swarm"] = True

        if "Registering self with peer ID:" in line:
            match = re.search(r"peer ID: (\w+)", line)
            if match:
                status["peer_id"] = match.group(1)

        if "Hello" in line:
            match = re.search(r"Hello (.+?) 🦮", line)
            if match:
                status["nickname"] = match.group(1).strip()

        if "Starting training" in line:
            status["training_started"] = True

        if "📈 Training round" in line:
            match = re.search(r"round: (\d+)", line)
            if match:
                round_num = int(match.group(1))
                status["rounds_tracked"] += 1
                status["last_round"] = round_num

        if "Sliding Window Attention" in line or "`use_cache=True`" in line:
            status["warnings"].append(line.strip())

    return status


def print_status(status):
    print("🔍 Gensyn Node Health Check")
    print("-" * 35)
    print(f"✅ Connected to testnet: {status['connected']}")
    print(f"🐝 Joined swarm: {status['joined_swarm']}")
    print(f"🔐 Peer ID: {status['peer_id'] or '—'}")
    print(f"📛 Nickname: {status['nickname'] or '—'}")
    print(f"🚀 Training started: {status['training_started']}")
    print(f"📈 Rounds tracked: {status['rounds_tracked']}")
    if status['last_round'] is not None:
        print(f"🔁 Last round: {status['last_round']}")
    if status['warnings']:
        print("\n⚠️ Warnings:")
        for w in status["warnings"]:
            print("   -", w)


if __name__ == "__main__":
    path = Path(LOG_PATH)
    if not path.exists():
        print(f"❌ Log file not found: {LOG_PATH}")
    else:
        log_text = path.read_text()
        status = parse_log(log_text)
        print_status(status)
