#!/bin/bash

# Redirect all output to a log file
exec > /var/log/setup_script.log 2>&1

echo "Start script - $(date)"

WORKSPACE_DIR="/home/ubuntu"

# System update
echo "Updating packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Installing Docker
echo "Installing Docker..."
sudo apt-get install -y docker.io

# Installing Git
echo "Installing Git..."
sudo apt-get install -y git

# Starting and activating Docker
echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Kash setup
echo "Cloning kash ..."
git clone https://github.com/kalisio/kash.git "$WORKSPACE_DIR/kash"
. "$WORKSPACE_DIR/kash/kash.sh"

# Installing Sops
echo "Installing Sops..."
mkdir -p /home/ubuntu/.local/bin
curl -LsS -o /home/ubuntu/.local/bin/sops https://github.com/getsops/sops/releases/download/v$SOPS_VERSION/sops-v$SOPS_VERSION.linux.amd64
chmod +x /home/ubuntu/.local/bin/sops
export PATH=$PATH:/home/ubuntu/.local/bin
echo "Setting SOPS_AGE_KEY..."
export SOPS_AGE_KEY="${SOPS_AGE_KEY}"

# Environment setup
echo "Cloning ${DEVELOPMENT_REPO_URL} ..."
git clone "${DEVELOPMENT_REPO_URL}" "$WORKSPACE_DIR/development"
load_env_files "$WORKSPACE_DIR/development/common/irsn_harbor.enc.env"
load_value_files "$WORKSPACE_DIR/development/common/IRSN_HARBOR_PASSWORD.enc.value"
echo "Cloning ${RCLONE_CONFIG_REPO_URL} for rclone.conf ..."
git clone "${RCLONE_CONFIG_REPO_URL}" "$WORKSPACE_DIR/rclone-config"
load_env_files "$WORKSPACE_DIR/rclone-config/rclone.enc.conf"
RCLONE_CONFIG_PATH="$WORKSPACE_DIR/rclone-config/rclone.dec.conf"

# Harbor registry connection
echo "Connecting to Harbor..."
docker login --username "$IRSN_HARBOR_USERNAME" --password-stdin "$IRSN_HARBOR_URL" < "$IRSN_HARBOR_PASSWORD"

# Download Docker image
echo "Download ${DOCKER_IMAGE}..."
sudo docker pull "${DOCKER_IMAGE}"

# Launch container
echo "Container launch with Artillery..."
sudo docker run -d \
  -e TARGET="${TARGET}" \
  -e ENVIRONMENT="${ENVIRONMENT}" \
  -e ADMIN_JWT_ACCESS_TOKEN="${ADMIN_JWT_ACCESS_TOKEN}" \
  -e LOW_DURATION="${LOW_DURATION}" \
  -e LOW_ARRIVAL_RATE="${LOW_ARRIVAL_RATE}" \
  -e LOW_MAX_VUSERS="${LOW_MAX_VUSERS}" \
  -e MEDIUM_DURATION="${MEDIUM_DURATION}" \
  -e MEDIUM_ARRIVAL_RATE="${MEDIUM_ARRIVAL_RATE}" \
  -e MEDIUM_MAX_VUSERS="${MEDIUM_MAX_VUSERS}" \
  -e HIGH_DURATION="${HIGH_DURATION}" \
  -e HIGH_ARRIVAL_RATE="${HIGH_ARRIVAL_RATE}" \
  -e HIGH_MAX_VUSERS="${HIGH_MAX_VUSERS}" \
  -v "$RCLONE_CONFIG_PATH:/home/node/.config/rclone/rclone.conf:ro" \
  "${DOCKER_IMAGE}" bash -c "${COMMAND}"

echo "Script completed - $(date)"