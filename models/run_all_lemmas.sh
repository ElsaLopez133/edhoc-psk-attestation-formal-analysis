#!/usr/bin/env bash
set -e

SPTHY="edhoc_psk_attestation_seq_sapic.spthy"
LEMMA_LIST="lemmas.txt"

OUTDIR="results"
PV_DIR="$OUTDIR/pv"
LOG_DIR="$OUTDIR/logs"

mkdir -p "$PV_DIR" "$LOG_DIR"

# Add timestamp to results CSV
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS="$OUTDIR/results_uni_backgound_check_$TIMESTAMP.csv"
echo "lemma,status,time_sec" > "$RESULTS"

while read -r LEMMA; do
    [[ -z "$LEMMA" || "$LEMMA" =~ ^# ]] && continue  # skip empty lines or comments

    echo "=== Running $LEMMA ==="

    PV_FILE="$PV_DIR/${LEMMA}_uni_background_check.pv"
    LOG_FILE="$LOG_DIR/${LEMMA}_uni_background_check.log"
    TIME_FILE="$LOG_DIR/${LEMMA}_uni_background_check.time"

    # 1. Generate ProVerif model from Tamarin (single lemma)
    tamarin-prover \
        -m=proverif \
        -DLeakShare \
        -DLeakSKey \
        --prove="$LEMMA" \
        "$SPTHY" \
        | awk '
        /^reduc / { last_reduc = NR }
        { lines[NR] = $0 }
        END {
          for (i = 1; i <= NR; i++) {
            print lines[i]
            if (i == last_reduc) {
              print ""
              print "set preciseActions = true."
              print "set simplifyProcess = false."
              print "set reconstructTrace = false."
              print ""
            }
          }
        }
        ' > "$PV_FILE"

    # 3. Run ProVerif with timing
    /usr/bin/time -f "%e" \
        proverif "$PV_FILE" \
        > "$LOG_FILE" \
        2> "$TIME_FILE"

    TIME=$(cat "$TIME_FILE")

    # 4. Extract result
    if grep -q "RESULT.*is true" "$LOG_FILE"; then
        STATUS="PASS"
    elif grep -q "RESULT.*is false" "$LOG_FILE"; then
        STATUS="FAIL"
    else
        STATUS="UNKNOWN"
    fi

    echo "$LEMMA,$STATUS,$TIME" >> "$RESULTS"

done < "$LEMMA_LIST"

echo "Results saved to $RESULTS"
