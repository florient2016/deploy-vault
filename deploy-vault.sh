#!/usr/bin env bash

# 📥 Download the latest Vault binary
echo "🔍 Downloading HashiCorp Vault..."
wget https://releases.hashicorp.com/vault/1.15.4/vault_1.15.4_linux_amd64.zip

# 📦 Extract and install
unzip vault_1.15.4_linux_amd64.zip
sudo mv vault /usr/bin/

# ✅ Verify installation
vault version
echo "🎉 Vault installed successfully!"

# 🔧 Configure Vault
# 👤 Create a dedicated vault user for security
echo "👤 Creating vault user..."
sudo useradd --system --home /etc/vault --shell /bin/false vault

# 📁 Set up directories with proper permissions
echo "📁 Creating directories..."
sudo mkdir -p /opt/vault/data
sudo mkdir -p /etc/vault

# vault.hcl configuration file
echo "🔧 Creating vault.hcl config file..."
sudo tee /etc/vault/vault.hcl > /dev/null <<EOF
# 📝 /etc/vault/vault.hcl
# This is where the magic happens! ✨

ui = true                    # 🖥️ Enable the beautiful web UI
disable_mlock = true         # 🔓 Required for some environments

# 💾 File storage - simple but effective for single-node setups
storage "file" {
  path = "/opt/vault/data"
}

# 🌐 Network listener configuration
listener "tcp" {
  address     = "0.0.0.0:8200"    # 📡 Listen on all interfaces
  tls_disable = true                  # ⚠️ Disabled for demo - enable in production!
}

# 🔗 API and cluster addresses
api_addr = "http://YOUR_VAULT_VM_IP:8200"
cluster_addr = "http://YOUR_VAULT_VM_IP:8201"
EOF

# 📁 Set up directories with proper permissions
echo "📁 Creating directories..."
sudo chown -R vault:vault /opt/vault/data
sudo chown -R vault:vault /etc/vault

echo "🔧 Creating systemd service..."
sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description=HashiCorp Vault Service
Documentation=https://www.vaultproject.io/docs
After=network.target
ConditionFileNotEmpty=/etc/vault/vault.hcl

[Service]
User=vault
Group=vault
ExecStart=/usr/bin/vault server -config=/etc/vault/vault.hcl
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
Environment="VAULT_ADDR=http://0.0.0.0:8200"

[Install]
WantedBy=multi-user.target
EOF

# 🚀 Start your Vault service
echo "🚀 Starting Vault service..."
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

# ✅ Check if everything is running smoothly
sudo systemctl status vault
echo "🎉 Vault is now running as a service!"

# 🌍 Set the Vault address environment variable
export VAULT_ADDR='http://YOUR_VAULT_VM_IP:8200'

# 🔑 Initialize Vault - this is a one-time operation!
echo "🔑 Initializing Vault..."
vault operator init -key-shares=5 -key-threshold=3

# 📋 You'll see output like this:
# Unseal Key 1: AbCdEf1234567890...
# Unseal Key 2: GhIjKl1234567890...
# Unseal Key 3: MnOpQr1234567890...
# Unseal Key 4: StUvWx1234567890...
# Unseal Key 5: YzAbCd1234567890...
# 
# Initial Root Token: s.1234567890AbCdEf...

# 🔓 Unseal Vault with 3 of the 5 keys
echo "🔓 Unsealing Vault..."
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# 🔐 Authenticate with the root token
vault auth <root-token>

echo "🎉 Vault is now initialized and ready to use!"

