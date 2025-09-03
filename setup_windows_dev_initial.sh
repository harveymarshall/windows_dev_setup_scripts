# ======================================
# Windows + WSL Dev Environment Bootstrap
# ======================================

# --- Install Scoop (Windows package manager) ---
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    scoop bucket add extras
    scoop bucket add versions
}

# --- Windows Tools via Scoop ---
$windowsApps = @(
    "cursor",
    "vscode",              # Visual Studio Code
    "powertoys",           # Windows productivity
    "docker",              # Docker Desktop
    "azure-cli",           # Azure CLI (Windows side, optional)
    "azure-storage-explorer",
    "git",                 # Git
    "gh",                  # GitHub CLI
    "insomnia",            # API client (alternative to Postman)
    "dbeaver",             # DB client
    "azure-data-studio"    # Data & query tool
)

foreach ($app in $windowsApps) {
    scoop install $app
}

# --- Power BI Desktop (via Winget) ---
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "📊 Installing Power BI Desktop..."
    winget install --id=Microsoft.PowerBIDesktop -e --source winget
} else {
    Write-Host "⚠️ Winget not found. Please install Power BI Desktop manually from Microsoft Store."
}

# --- VS Code Extensions ---
$extensions = @(
    "ms-vscode-remote.remote-wsl",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-toolsai.jupyter",
    "ms-azuretools.vscode-azurefunctions",
    "ms-azuretools.vscode-azurestorage",
    "ms-azuretools.vscode-cosmosdb",
    "ms-azuretools.vscode-docker",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-azure-devops.azure-pipelines"
)

foreach ($ext in $extensions) {
    code --install-extension $ext
}

# --- Run setup inside WSL ---
wsl bash -c "bash -s" <<'EOF'
set -e

# Update & install base packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl unzip zip git python3-pip python3-venv

# Install uv (Python manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Install dbt-core + dbt-azure adapter
# uv tool install dbt-core
# uv tool install dbt-sqlserver
# uv tool install dbt-azure

# Azure CLI (Linux side)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Docker + Kubernetes tooling
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
sudo apt install -y kubectl
curl -s https://raw.githubusercontent.com/derailed/k9s/master/install.sh | bash

# Terraform
sudo apt install -y gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

EOF

Write-Host "✅ Dev environment setup complete! Restart terminal and VS Code to apply changes."
