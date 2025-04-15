import os

def check_outputs(log_path="training_output.log", expected_keys=["eval_loss", "eval_accuracy"]):
    if not os.path.exists(log_path):
        print(f"[❌] Log file {log_path} not found.")
        return False

    with open(log_path, "r") as f:
        content = f.read()

    for key in expected_keys:
        if key not in content:
            print(f"[⚠️] Missing key: {key}")
            return False

    print("[✅] All expected keys found in logs.")
    return True
