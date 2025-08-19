#!/bin/bash
set -e

# ======================================
#  EP LOGO Banner
# ======================================
echo ""
echo -e "\033[1;36m███████╗██████╗     ██╗      ██████╗  ██████╗ \033[0m"
echo -e "\033[1;36m██╔════╝██╔══██╗    ██║     ██╔═══██╗██╔════╝ \033[0m"
echo -e "\033[1;36m█████╗  ██████╔╝    ██║     ██║   ██║██║  ███╗\033[0m"
echo -e "\033[1;36m██╔══╝  ██╔═══╝     ██║     ██║   ██║██║   ██║\033[0m"
echo -e "\033[1;36m███████╗██║         ███████╗╚██████╔╝╚██████╔╝\033[0m"
echo -e "\033[1;36m╚══════╝╚═╝         ╚══════╝ ╚═════╝  ╚═════╝ \033[0m"
echo ""
echo -e "\033[1;32m        🚀 ETHSTORAGE PHASE 2 CEREMONY\033[0m"
echo ""

echo "🚀 Starting Ceremony Setup..."
echo "==============EARNPOINT========================"

# 1️⃣ Update & Install Dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential

# 2️⃣ Node.js check
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js v18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
    sudo apt install -y nodejs
    sudo npm install -g npm@9.2
else
    echo "✅ Node.js already installed: $(node -v)"
    echo "✅ npm version: $(npm -v)"
fi

# 3️⃣ Create or switch to working directory
if [ -d "$WORKDIR" ]; then
    echo "📂 Existing working directory found, switching..."
    cd "$WORKDIR"
else
    echo "📂 Creating new working directory..."
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"
fi

# 4️⃣ Install Phase2 CLI if not exists
if ! command -v phase2cli &> /dev/null; then
    echo "📦 Installing Phase2 CLI..."
    sudo npm install -g @p0tion/phase2cli
else
    echo "✅ Phase2 CLI already installed: $(phase2cli --version)"
fi

# 5️⃣ GitHub Authentication
echo "🔐 Checking GitHub authentication..."
phase2cli auth
echo ""
read -p "✅ If GitHub asked you to login, have you completed authorization? (yes/no): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo "❌ Authentication not confirmed. Exiting..."
    exit 1
fi

# 6️⃣ Ceremony systemd service
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
echo "⚙️ Creating systemd service at $SERVICE_FILE"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=EthStorage Ceremony Contributor Node
After=network.target

[Service]
WorkingDirectory=$WORKDIR
ExecStart=/usr/bin/env bash -c 'yes "" | phase2cli contribute -c ethstorage-v1-trusted-setup-ceremony'
Restart=always
RestartSec=10
User=$USER

[Install]
WantedBy=multi-user.target
EOL

# 7️⃣ Enable service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now $SERVICE_NAME

echo ""
echo "🎉 Ceremony service setup complete!"
echo "👉 Logs (node running): journalctl -u $SERVICE_NAME -f"
echo "👉 Stop service:        sudo systemctl stop $SERVICE_NAME"
echo "👉 Restart service:     sudo systemctl restart $SERVICE_NAME"
