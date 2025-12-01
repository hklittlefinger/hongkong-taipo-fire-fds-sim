#!/bin/bash
set -o pipefail

# --- CONFIGURATION ---
KEY_PATH=""
INSTANCES_FILE="instances.txt"

# --- FUNCTIONS ---

print_usage() {
    echo "Usage: $0 --key-path PATH [--instances-file FILE]"
    echo ""
    echo "Required arguments:"
    echo "  --key-path PATH           Path to SSH private key"
    echo ""
    echo "Optional arguments:"
    echo "  --instances-file FILE     Path to instances file (default: instances.txt)"
    echo ""
    echo "Example:"
    echo "  $0 --key-path ~/.ssh/fds-key-pair"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help | -h)
                print_usage
                exit 0
                ;;
            --key-path)
                KEY_PATH="$2"
                shift 2
                ;;
            --instances-file)
                INSTANCES_FILE="$2"
                shift 2
                ;;
            *)
                echo "ERROR: Unknown argument: $1" >&2
                print_usage
                exit 1
                ;;
        esac
    done
}

validate_arguments() {
    if [ -z "$KEY_PATH" ]; then
        echo "ERROR: --key-path is required" >&2
        echo ""
        print_usage
        return 1
    fi

    if [ ! -f "$KEY_PATH" ]; then
        echo "ERROR: Key file not found: $KEY_PATH" >&2
        return 1
    fi

    if [ ! -f "$INSTANCES_FILE" ]; then
        echo "ERROR: Instances file not found: $INSTANCES_FILE" >&2
        return 1
    fi
}

ssh_exec() {
    local IP=$1
    local COMMAND=$2
    ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -i "$KEY_PATH" "ubuntu@$IP" "$COMMAND" </dev/null
}

check_instance_status() {
    local IP=$1
    local INSTANCE_ID=$2
    local SIM_FILE=$3
    local REGION=$4

    echo "========================================"
    echo "Instance: $INSTANCE_ID"
    echo "IP: $IP"
    echo "File: $SIM_FILE"
    echo "Region: $REGION"
    echo "========================================"

    # Check if instance is running on AWS
    local INSTANCE_STATE
    INSTANCE_STATE=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null </dev/null)

    if [ "$INSTANCE_STATE" != "running" ]; then
        echo "Status: ⏹️  INSTANCE NOT RUNNING (state: ${INSTANCE_STATE:-unknown})"
        echo ""
        return 10
    fi

    # Check if SSH is accessible
    if ! ssh_exec "$IP" "exit" 2>/dev/null; then
        echo "Status: ⚠️  INSTANCE RUNNING BUT SSH NOT ACCESSIBLE"
        echo ""
        return 10
    fi

    # Check if tmux session exists
    if ! ssh_exec "$IP" "tmux has-session -t fds_run 2>/dev/null"; then
        echo "Status: ❌ TMUX SESSION NOT FOUND"
        echo ""
        return 10
    fi

    # Get last 20 lines of tmux output
    local TMUX_OUTPUT
    TMUX_OUTPUT=$(ssh_exec "$IP" "tmux capture-pane -p -t fds_run | tail -20")

    # Check if pane is dead (process exited)
    local PANE_DEAD
    PANE_DEAD=$(ssh_exec "$IP" "tmux display-message -p -t fds_run '#{pane_dead}'" 2>/dev/null || echo "")

    if [ "$PANE_DEAD" = "1" ]; then
        # Pane is dead, get exit status
        local EXIT_STATUS
        EXIT_STATUS=$(ssh_exec "$IP" "tmux display-message -p -t fds_run '#{pane_dead_status}'" 2>/dev/null || echo "")

        if [ "$EXIT_STATUS" = "0" ]; then
            echo "Status: ✅ COMPLETED"
            echo ""
            echo "Last output:"
            echo "$TMUX_OUTPUT" | tail -5
            echo ""
            return 2
        else
            echo "Status: ❌ ERROR (exit code: ${EXIT_STATUS:-unknown})"
            echo ""
            echo "Last output:"
            echo "$TMUX_OUTPUT"
            echo ""
            return 3
        fi
    fi

    # Extract current time step if running
    local TIME_STEP
    TIME_STEP=$(echo "$TMUX_OUTPUT" | grep "Time Step:" | tail -1)
    if [ -n "$TIME_STEP" ]; then
        echo "Status: 🔄 RUNNING"
        echo "$TIME_STEP"

        # Extract simulation time and calculate progress
        local CURRENT_SIM_TIME
        CURRENT_SIM_TIME=$(echo "$TIME_STEP" | sed -n 's/.*Simulation Time:[[:space:]]*\([0-9.]*\).*/\1/p')
        CURRENT_SIM_TIME=${CURRENT_SIM_TIME:-0}
        local TARGET_TIME=3600.0  # From T_END in FDS files

        # Get process start time from FDS output file birth time (Linux)
        local START_TIME
        local SIM_BASE="${SIM_FILE%.fds}"
        START_TIME=$(ssh_exec "$IP" "stat -c %W ${SIM_BASE}.out 2>/dev/null || echo 0")
        local CURRENT_TIME=$(date +%s)
        local ELAPSED_WALL_TIME=$((CURRENT_TIME - START_TIME))

        if [ "$ELAPSED_WALL_TIME" -gt 0 ] && [ "$(echo "$CURRENT_SIM_TIME > 0" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
            # Calculate progress percentage
            local PROGRESS=$(printf "%.2f" $(echo "scale=4; ($CURRENT_SIM_TIME * 100) / $TARGET_TIME" | bc -l))

            # Calculate elapsed wall minutes
            local ELAPSED_WALL_MINS=$(echo "scale=2; $ELAPSED_WALL_TIME / 60" | bc -l)

            # Calculate rate (sim seconds per wall minute)
            local RATE=$(printf "%.2f" $(echo "scale=4; $CURRENT_SIM_TIME / $ELAPSED_WALL_MINS" | bc -l))

            # Estimate remaining time
            local REMAINING_SIM_TIME=$(echo "$TARGET_TIME - $CURRENT_SIM_TIME" | bc -l)
            local ESTIMATED_WALL_MINS=$(echo "scale=0; $REMAINING_SIM_TIME / $RATE" | bc -l)

            # Format elapsed time
            local ELAPSED_HOURS=$((ELAPSED_WALL_TIME / 3600))
            local ELAPSED_MINS=$(((ELAPSED_WALL_TIME % 3600) / 60))

            # Format estimated finish time
            local ESTIMATED_WALL_SECONDS=$(echo "$ESTIMATED_WALL_MINS * 60" | bc)
            local FINISH_TIMESTAMP=$((CURRENT_TIME + ESTIMATED_WALL_SECONDS))
            local FINISH_TIME=$(date -d "@$FINISH_TIMESTAMP" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -r "$FINISH_TIMESTAMP" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
            local ETA_HOURS=$(echo "scale=0; $ESTIMATED_WALL_MINS / 60" | bc)
            local ETA_MINS=$(echo "scale=0; $ESTIMATED_WALL_MINS % 60" | bc)

            echo "Progress: ${PROGRESS}% (${CURRENT_SIM_TIME}s / ${TARGET_TIME}s)"
            echo "Elapsed: ${ELAPSED_HOURS}h ${ELAPSED_MINS}m"
            echo "Rate: ${RATE} sim-sec/wall-min"
            echo "ETA: ${ETA_HOURS}h ${ETA_MINS}m (finish: $FINISH_TIME)"
        fi

        echo ""
        echo "Last few time steps:"
        echo "$TMUX_OUTPUT" | grep "Time Step:" | tail -5
        echo ""
        return 0
    else
        echo "Status: ⚠️  UNKNOWN - No time step output"
        echo ""
        echo "Last output:"
        echo "$TMUX_OUTPUT"
        echo ""
        return 1
    fi
}

check_all_instances() {
    local TOTAL=0
    local RUNNING=0
    local COMPLETED=0
    local ERRORS=0
    local UNKNOWN=0
    local NOT_RUNNING=0

    while IFS='|' read -r IP INSTANCE_ID SIM_FILE REGION; do
        # Skip empty lines
        [ -z "$IP" ] && continue

        : $((TOTAL++))

        check_instance_status "$IP" "$INSTANCE_ID" "$SIM_FILE" "$REGION"
        local STATUS=$?

        # Return codes: 0=running, 1=unknown, 2=completed, 3=error, 10=not running/inaccessible
        case $STATUS in
            0)  : $((RUNNING++)) ;;
            1)  : $((UNKNOWN++)) ;;
            2)  : $((COMPLETED++)) ;;
            3)  : $((ERRORS++)) ;;
            10) : $((NOT_RUNNING++)) ;;
            *)  : $((UNKNOWN++)) ;;
        esac
    done < "$INSTANCES_FILE"

    echo "========================================"
    echo "SUMMARY"
    echo "========================================"
    echo "Total instances: $TOTAL"
    echo "Running simulations: $RUNNING"
    echo "Completed: $COMPLETED"
    echo "Errors: $ERRORS"
    echo "Unknown status: $UNKNOWN"
    echo "Not running/inaccessible: $NOT_RUNNING"
    echo "========================================"
}

# --- MAIN ---

main() {
    parse_arguments "$@"

    if ! validate_arguments; then
        exit 1
    fi

    echo "--- FDS Job Status Checker ---"
    echo "Instances file: $INSTANCES_FILE"
    echo ""

    check_all_instances
}

main "$@"
