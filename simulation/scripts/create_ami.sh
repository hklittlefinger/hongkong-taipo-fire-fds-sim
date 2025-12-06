#!/bin/bash
#
# create_ami.sh - Create, test, and distribute FDS AMI
#
# Usage:
#   ./create_ami.sh --instance-id <id> --key-path <path> [options]
#
# Options:
#   --source-region REG   Source region (default: eu-north-1)
#   --regions REGIONS     Comma-separated target regions for distribution
#   --name NAME           AMI name prefix
#   --skip-test           Skip AMI testing phase
#   --skip-cleanup        Keep test instance after testing
#
# Examples:
#   ./create_ami.sh --instance-id i-abc123 --key-path ~/.ssh/key.pem
#   ./create_ami.sh --instance-id i-abc123 --key-path ~/.ssh/key.pem --skip-test
#   ./create_ami.sh --instance-id i-abc123 --key-path ~/.ssh/key.pem --regions "eu-south-1,ap-northeast-1"
#

set -e

# Default values
SOURCE_REGION="eu-north-1"
TARGET_REGIONS="eu-south-1,eu-south-2,ap-northeast-1,ap-southeast-3"
AMI_PREFIX="fds-6.10.1-hypre-sundials"
AMI_DESCRIPTION="FDS 6.10.1 with HYPRE v2.32.0 and Sundials v6.7.0 - Intel oneAPI 2025.3 - Ubuntu 24.04"
SKIP_TEST=false
SKIP_CLEANUP=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf '%b[INFO]%b %s\n' "$BLUE" "$NC" "$1"; }
log_success() { printf '%b[SUCCESS]%b %s\n' "$GREEN" "$NC" "$1"; }
log_warn() { printf '%b[WARN]%b %s\n' "$YELLOW" "$NC" "$1"; }
log_error() { printf '%b[ERROR]%b %s\n' "$RED" "$NC" "$1"; }

# ==============================================================================
# Argument parsing and validation
# ==============================================================================
usage() {
    cat << EOF
Usage: $0 --instance-id <id> --key-path <path> [options]

Create, test, and distribute a custom FDS AMI.

Required:
  --instance-id ID      Source instance ID to create AMI from
  --key-path PATH       Path to SSH key for testing

Optional:
  --source-region REG   Source region (default: eu-north-1)
  --regions REGIONS     Comma-separated target regions for distribution
                        (default: eu-south-1,eu-south-2,ap-northeast-1,ap-southeast-3)
  --skip-test           Skip AMI testing phase
  --skip-cleanup        Keep test instance after testing
  --name NAME           AMI name prefix (default: fds-6.10.1-hypre-sundials)
  -h, --help            Show this help message

Examples:
  $0 --instance-id i-abc123 --key-path ~/.ssh/key.pem
  $0 --instance-id i-abc123 --key-path ~/.ssh/key.pem --skip-test
  $0 --instance-id i-abc123 --key-path ~/.ssh/key.pem --regions "eu-south-1"
EOF
    exit 1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --instance-id)
                INSTANCE_ID="$2"
                shift 2
                ;;
            --key-path)
                KEY_PATH="$2"
                shift 2
                ;;
            --source-region)
                SOURCE_REGION="$2"
                shift 2
                ;;
            --regions)
                TARGET_REGIONS="$2"
                shift 2
                ;;
            --name)
                AMI_PREFIX="$2"
                shift 2
                ;;
            --skip-test)
                SKIP_TEST=true
                shift
                ;;
            --skip-cleanup)
                SKIP_CLEANUP=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

validate_args() {
    if [[ -z "$INSTANCE_ID" ]]; then
        log_error "Missing required argument: --instance-id"
        usage
    fi

    if [[ -z "$KEY_PATH" ]] && [[ "$SKIP_TEST" != "true" ]]; then
        log_error "Missing required argument: --key-path (required unless --skip-test)"
        usage
    fi

    if [[ "$SKIP_TEST" != "true" ]] && [[ ! -f "$KEY_PATH" ]]; then
        log_error "SSH key not found: $KEY_PATH"
        exit 1
    fi
}

# ==============================================================================
# Step 1: Security cleanup on source instance
# ==============================================================================
cleanup_instance() {
    local instance_ip="$1"

    log_info "Step 1: Running security cleanup on source instance..."
    log_info "Instance IP: $instance_ip"

    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 -i "$KEY_PATH" "ubuntu@$instance_ip" << 'EOF'
        echo "Removing shell history..."
        sudo rm -f /root/.bash_history /home/*/.bash_history
        history -c

        echo "Removing SSH host keys..."
        sudo rm -f /etc/ssh/ssh_host_*

        echo "Cleaning temp directories..."
        sudo rm -rf /tmp/* /var/tmp/*

        echo "Cleaning log files..."
        sudo find /var/log -type f -name "*.log" -delete
        sudo find /var/log -type f -name "*.gz" -delete
        sudo journalctl --rotate 2>/dev/null || true
        sudo journalctl --vacuum-time=1s 2>/dev/null || true

        echo "Resetting machine-id..."
        sudo truncate -s 0 /etc/machine-id
        sudo rm -f /var/lib/dbus/machine-id

        echo "Cleaning cloud-init state..."
        sudo cloud-init clean --logs 2>/dev/null || true

        echo "Clearing apt cache..."
        sudo apt-get clean
        sudo rm -rf /var/lib/apt/lists/*

        echo "Cleanup complete."
EOF

    log_success "Security cleanup complete"
}

# Final cleanup that removes SSH access (run right before AMI creation)
final_cleanup() {
    local instance_ip="$1"

    log_info "Running final security cleanup (removes SSH access)..."

    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 -i "$KEY_PATH" "ubuntu@$instance_ip" << 'EOF'
        echo "Removing authorized_keys..."
        sudo rm -f /root/.ssh/authorized_keys
        rm -f ~/.ssh/authorized_keys

        echo "Removing SSH known_hosts..."
        sudo rm -f /root/.ssh/known_hosts
        rm -f ~/.ssh/known_hosts

        echo "Final cleanup complete."
EOF

    log_success "Final security cleanup complete"
}

# ==============================================================================
# Step 2: Create AMI
# ==============================================================================
create_ami() {
    log_info "Step 2: Creating AMI from instance $INSTANCE_ID..."

    local ami_name="${AMI_PREFIX}-$(date +%Y%m%d-%H%M%S)"

    local ami_id
    ami_id=$(aws ec2 create-image \
        --region "$SOURCE_REGION" \
        --instance-id "$INSTANCE_ID" \
        --name "$ami_name" \
        --description "$AMI_DESCRIPTION" \
        --query 'ImageId' --output text)

    log_info "AMI ID: $ami_id"
    log_info "AMI Name: $ami_name"
    log_info "Waiting for AMI to become available (this may take 5-10 minutes)..."

    aws ec2 wait image-available --region "$SOURCE_REGION" --image-ids "$ami_id"

    log_success "AMI $ami_id is now available"

    echo "$ami_id"
}

# ==============================================================================
# Step 3: Test AMI
# ==============================================================================
test_ami() {
    local ami_id="$1"

    log_info "Step 3: Testing AMI $ami_id..."

    # Get VPC and subnet from source instance
    local vpc_id subnet_id sg_id
    read -r vpc_id subnet_id sg_id <<< $(aws ec2 describe-instances --region "$SOURCE_REGION" \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].[VpcId,SubnetId,SecurityGroups[0].GroupId]' \
        --output text)

    # Get key name from source instance
    local key_name
    key_name=$(aws ec2 describe-instances --region "$SOURCE_REGION" \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].KeyName' --output text)

    log_info "Launching test instance..."

    local test_instance_id
    test_instance_id=$(aws ec2 run-instances \
        --region "$SOURCE_REGION" \
        --image-id "$ami_id" \
        --instance-type t3.medium \
        --key-name "$key_name" \
        --security-group-ids "$sg_id" \
        --subnet-id "$subnet_id" \
        --associate-public-ip-address \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=ami-test-$ami_id}]" \
        --query 'Instances[0].InstanceId' --output text)

    log_info "Test instance: $test_instance_id"
    log_info "Waiting for instance to be running..."

    aws ec2 wait instance-running --region "$SOURCE_REGION" --instance-ids "$test_instance_id"

    # Get test instance IP
    local test_ip
    test_ip=$(aws ec2 describe-instances --region "$SOURCE_REGION" \
        --instance-ids "$test_instance_id" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

    log_info "Test instance IP: $test_ip"
    log_info "Waiting for SSH to be available..."

    # Wait for SSH
    local max_attempts=30
    local attempt=0
    while ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$KEY_PATH" \
        "ubuntu@$test_ip" "echo 'SSH ready'" 2>/dev/null; do
        attempt=$((attempt + 1))
        if [[ $attempt -ge $max_attempts ]]; then
            log_error "SSH not available after $max_attempts attempts"
            terminate_test_instance "$test_instance_id"
            return 1
        fi
        sleep 10
    done

    log_info "Running FDS verification tests..."

    # Run tests
    local test_result=0
    ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" "ubuntu@$test_ip" << 'EOF' || test_result=$?
        set -e
        echo "=== Test 1: Check FDS binary exists ==="
        ls -la /opt/fds/bin/fds

        echo ""
        echo "=== Test 2: Check FDS runs ==="
        source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
        /opt/fds/bin/fds 2>&1 | head -20

        echo ""
        echo "=== Test 3: Check libimf.so is available ==="
        ldd /opt/fds/bin/fds | grep libimf

        echo ""
        echo "=== Test 4: Check MPI works ==="
        which mpiexec
        mpiexec --version | head -3

        echo ""
        echo "=== All tests passed ==="
EOF

    if [[ $test_result -ne 0 ]]; then
        log_error "AMI tests failed!"
        if [[ "$SKIP_CLEANUP" != "true" ]]; then
            terminate_test_instance "$test_instance_id"
        else
            log_warn "Test instance kept for debugging: $test_instance_id ($test_ip)"
        fi
        return 1
    fi

    log_success "All AMI tests passed!"

    # Cleanup test instance
    if [[ "$SKIP_CLEANUP" != "true" ]]; then
        terminate_test_instance "$test_instance_id"
    else
        log_warn "Test instance kept: $test_instance_id ($test_ip)"
    fi

    return 0
}

terminate_test_instance() {
    local instance_id="$1"
    log_info "Terminating test instance $instance_id..."
    aws ec2 terminate-instances --region "$SOURCE_REGION" --instance-ids "$instance_id" > /dev/null
    log_success "Test instance terminated"
}

# ==============================================================================
# Step 4: Distribute to other regions
# ==============================================================================
distribute_ami() {
    local ami_id="$1"

    if [[ -z "$TARGET_REGIONS" ]]; then
        log_info "No target regions specified, skipping distribution"
        return
    fi

    log_info "Step 4: Distributing AMI to other regions..."

    # Get AMI name
    local ami_name
    ami_name=$(aws ec2 describe-images --region "$SOURCE_REGION" \
        --image-ids "$ami_id" \
        --query 'Images[0].Name' --output text)

    local copied_amis=()

    IFS=',' read -ra REGIONS <<< "$TARGET_REGIONS"
    for region in "${REGIONS[@]}"; do
        region=$(echo "$region" | xargs)  # trim whitespace

        log_info "Copying to $region..."

        local copied_ami_id
        copied_ami_id=$(aws ec2 copy-image \
            --region "$region" \
            --source-region "$SOURCE_REGION" \
            --source-image-id "$ami_id" \
            --name "$ami_name" \
            --description "$AMI_DESCRIPTION" \
            --query 'ImageId' --output text)

        log_info "  $region: $copied_ami_id (copying...)"
        copied_amis+=("$region:$copied_ami_id")
    done

    log_info "Waiting for all copies to complete..."

    for entry in "${copied_amis[@]}"; do
        local region="${entry%%:*}"
        local ami="${entry##*:}"

        log_info "Waiting for $ami in $region..."
        aws ec2 wait image-available --region "$region" --image-ids "$ami"
        log_success "  $region: $ami is available"
    done

    log_success "AMI distributed to all target regions"

    # Print summary
    echo ""
    echo "=========================================="
    echo "AMI Distribution Summary"
    echo "=========================================="
    echo "Source: $SOURCE_REGION: $ami_id"
    for entry in "${copied_amis[@]}"; do
        local region="${entry%%:*}"
        local ami="${entry##*:}"
        echo "Copy:   $region: $ami"
    done
    echo "=========================================="
}

# ==============================================================================
# Main
# ==============================================================================
main() {
    parse_args "$@"
    validate_args

    echo ""
    echo "=========================================="
    echo "FDS AMI Builder"
    echo "=========================================="
    echo "Source Instance: $INSTANCE_ID"
    echo "Source Region:   $SOURCE_REGION"
    echo "Target Regions:  $TARGET_REGIONS"
    echo "Skip Test:       $SKIP_TEST"
    echo "=========================================="
    echo ""

    # Get instance IP for cleanup steps
    local instance_ip
    instance_ip=$(aws ec2 describe-instances --region "$SOURCE_REGION" \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

    if [[ "$instance_ip" == "None" ]] || [[ -z "$instance_ip" ]]; then
        log_error "Could not get instance IP. Is the instance running?"
        exit 1
    fi

    # Step 1: Cleanup
    if [[ "$SKIP_TEST" != "true" ]]; then
        cleanup_instance "$instance_ip"
    else
        log_warn "Skipping cleanup (--skip-test implies instance is already clean)"
    fi

    # Step 1.5: Final cleanup (removes SSH access)
    final_cleanup "$instance_ip"

    # Step 2: Create AMI
    local ami_id
    ami_id=$(create_ami)

    # Step 3: Test
    if [[ "$SKIP_TEST" != "true" ]]; then
        if ! test_ami "$ami_id"; then
            log_error "AMI testing failed. AMI created but not distributed."
            log_error "AMI ID: $ami_id"
            exit 1
        fi
    else
        log_warn "Skipping AMI testing (--skip-test)"
    fi

    # Step 4: Distribute
    distribute_ami "$ami_id"

    echo ""
    log_success "AMI pipeline complete!"
    echo ""
    echo "Primary AMI: $ami_id ($SOURCE_REGION)"
    echo ""
}

main "$@"
