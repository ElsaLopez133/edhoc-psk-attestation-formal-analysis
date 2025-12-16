import subprocess
import csv
import re
import time
import os
from datetime import datetime 

# ---- Configuration ----
lemmas = [
    "pfs",
    "secretR_psk",
    "secretI_psk",
    "secret_psk",
    "authRI_psk_non_inj",
    "authIR_psk_non_inj",
    "full_agreement_RI",
    "full_agreement_IR",
]

flag_sets = [
    [],
    ["-DLeakShare"],
    ["-DLeakSKey"],
    ["-DLeakShare", "-DLeakSKey"],
    ["-DPQDL"],
]

tamarin_file = "edhoc_psk_sapic.spthy"
timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
output_csv = f"results/tamarin_results_{timestamp}.csv"


def run_tamarin(lemma, flags):
    cmd = [
        "tamarin-prover",
        f"--prove={lemma}",
        tamarin_file,
        "--derivcheck-timeout=0",
        "-s=10",
    ] + flags

    proc = subprocess.run(cmd, capture_output=True, text=True)
    out = proc.stdout + proc.stderr

    # Extract processing time
    time_match = re.search(r"processing time:\s*([\d.]+)s", out)
    runtime = float(time_match.group(1)) if time_match else None

    # Extract status + steps
    line_match = re.search(
        rf"{lemma} \([^)]+\): (verified|falsified|analysis incomplete) \((\d+) steps\)",
        out,
    )
    if line_match:
        status = line_match.group(1)
        steps = int(line_match.group(2))
    else:
        status, steps = "not found", None

    return runtime, steps, status, " ".join(flags) if flags else "None"


# ---- Create file with header if it doesn't exist ----
new_file = not os.path.exists(output_csv)
with open(output_csv, "a", newline="") as f:
    writer = csv.writer(f)
    if new_file:
        writer.writerow(["Lemma", "Status", "Steps", "ProcessingTime(s)", "Flags"])

    for lemma in lemmas:
        for flags in flag_sets:
            runtime, steps, status, flag_str = run_tamarin(lemma, flags)
            writer.writerow([lemma, status, steps, runtime, flag_str])
            print(f"✅ {lemma} {flag_str} -> {status}, {steps} steps, {runtime:.2f}s")

print(f"\nResults appended to {output_csv}")