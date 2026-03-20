#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "请用 root 执行"
  exit 1
fi

NODE_MAJOR="${NODE_MAJOR:-22}"
SWAP_SIZE_MB="${SWAP_SIZE_MB:-2048}"
GATEWAY_HEAP_MB="${GATEWAY_HEAP_MB:-}"
GATEWAY_PORT="${GATEWAY_PORT:-18789}"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-latest}"

export DEBIAN_FRONTEND=noninteractive
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

echo "==> 1. 安装基础依赖"
apt update
apt install -y sudo curl git ca-certificates python3 make g++ cmake build-essential

echo "==> 2. 配置 swap（如无）"
if ! swapon --show | grep -q '/swapfile'; then
  fallocate -l ${SWAP_SIZE_MB}M /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_SIZE_MB}
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "==> 3. 安装 Node.js ${NODE_MAJOR}"
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash -
apt install -y nodejs

echo "==> 4. 配置 npm/pnpm"
npm config set registry https://registry.npmmirror.com
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
npm config set fetch-timeout 300000
npm i -g pnpm

export PNPM_HOME=/root/.local/share/pnpm
export PATH="$PNPM_HOME:$PATH"
mkdir -p "$PNPM_HOME"
pnpm config set global-bin-dir "$PNPM_HOME"
pnpm config set registry https://registry.npmmirror.com

grep -q 'PNPM_HOME=/root/.local/share/pnpm' /root/.bashrc || cat >> /root/.bashrc <<'EOF'
export PNPM_HOME=/root/.local/share/pnpm
export PATH="$PNPM_HOME:$PATH"
EOF

echo "==> 5. 修 GitHub SSH -> HTTPS"
git config --global url."https://github.com/".insteadOf git@github.com:
git config --global url."https://github.com/".insteadOf ssh://git@github.com/
git config --global url."https://github.com/".insteadOf git+ssh://git@github.com/
git config --global url."https://".insteadOf git+ssh://

echo "==> 6. 安装 OpenClaw"
if [[ "$OPENCLAW_VERSION" == "latest" ]]; then
  pnpm add -g openclaw
else
  pnpm add -g "openclaw@${OPENCLAW_VERSION}"
fi

echo "==> 7. 初始化 Gateway"
chmod 700 /root/.openclaw 2>/dev/null || true
openclaw gateway install --runtime node --port "$GATEWAY_PORT" || true
openclaw config set gateway.mode local

mkdir -p /root/.config/systemd/user
SERVICE_FILE=/root/.config/systemd/user/openclaw-gateway.service
if [[ -f "$SERVICE_FILE" ]]; then
  sed -i '/^Environment=NODE_OPTIONS=/d' "$SERVICE_FILE"

  if [[ -n "${GATEWAY_HEAP_MB}" ]]; then
    sed -i '/^\[Service\]/a Environment=NODE_OPTIONS=--max-old-space-size='"$GATEWAY_HEAP_MB" "$SERVICE_FILE"
    echo "==> 已启用 OOM 保护: --max-old-space-size=${GATEWAY_HEAP_MB}"
  else
    echo "==> 未启用 OOM 保护（如需开启，请传入 GATEWAY_HEAP_MB）"
  fi

  systemctl --user daemon-reload || true
  systemctl --user restart openclaw-gateway.service || true
fi

openclaw gateway restart || openclaw gateway start || true

echo
echo "==> 基础部署完成"
openclaw --version || true
openclaw gateway status || true

echo
echo "Dashboard:"
echo "http://127.0.0.1:${GATEWAY_PORT}/"
echo
echo "如需本地访问，可执行："
echo "ssh -L ${GATEWAY_PORT}:127.0.0.1:${GATEWAY_PORT} root@你的服务器IP"
