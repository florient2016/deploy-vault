# HashiCorp Vault Automated Deployment (RHEL) - Bash & Ansible

This repository provides two approaches for deploying and configuring HashiCorp Vault on a RHEL-based system:  
- A **Bash script** for manual, step-by-step installation and setup  
- An **Ansible playbook** for automated, repeatable, and idempotent deployment

---

## Overview

HashiCorp Vault is a powerful tool for managing secrets and protecting sensitive data. The provided scripts automate the installation, configuration, and service setup of Vault, ensuring best practices such as running Vault as a dedicated system user and managing it as a systemd service.

---

## Files

### 1. `deploy-vault.sh` (Bash Script)

- **Purpose:**  
  Installs Vault, creates a dedicated user, sets up directories and permissions, generates a basic configuration, creates a systemd service, and starts Vault.
- **Key Steps:**  
  - Downloads and installs Vault binary  
  - Creates a `vault` system user  
  - Sets up `/opt/vault/data` and `/etc/vault` directories  
  - Generates a `vault.hcl` config file with file storage and TCP listener  
  - Creates and enables a systemd service for Vault  
  - Starts Vault and sets the `VAULT_ADDR` environment variable  
  - Provides commands to initialize and unseal Vault, and to authenticate with the root token  
- **Manual Steps:**  
  - Replace `YOUR_VAULT_VM_IP` in the config with your server's IP  
  - Run the `vault operator init` and `vault operator unseal` commands as shown in the script

### 2. `deploy-vault.yaml` (Ansible Playbook)

- **Purpose:**  
  Automates the entire Vault deployment process for one or more hosts using Ansible.
- **Key Features:**  
  - Uses variables for Vault version, directories, and addresses  
  - Installs required packages (`wget`, `unzip`)  
  - Downloads and installs Vault  
  - Creates system user and directories with correct permissions  
  - Templates the Vault configuration and systemd service file  
  - Starts and enables the Vault service  
  - Sets the `VAULT_ADDR` environment variable system-wide  
  - Waits for the Vault API to become available  
  - (Optional/manual) Steps for initialization and unsealing are included as comments for security best practices

---

## How to Use

### Bash Script

1. Edit `deploy-vault.sh` and replace `YOUR_VAULT_VM_IP` with your server's IP address.
2. Run the script as root:
   ```bash
   bash deploy-vault.sh
   ```
3. Follow the prompts to initialize and unseal Vault.
Ansible Playbook

- Edit variables in deploy-vault.yaml as needed (especially vault_api_addr and vault_cluster_addr).
- Add your target host(s) to your Ansible inventory under the group vault.
- Run the playbook:
   ```bash
   ansible-playbook -i inventory deploy-vault.yaml
   ```
- Initialize and unseal Vault manually, or adapt the commented tasks for automation if desired.