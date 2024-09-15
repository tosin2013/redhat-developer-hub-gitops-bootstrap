#!/bin/bash 

if [ -f .venv/bin/activate ]; then
  echo "Virtual environment already exists. Skipping setup."
else
    python3 -m venv .venv
    source .venv/bin/activate
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible hvac kubernetes
    source .venv/bin/activate
else 
    source .venv/bin/activate
fi

ensure_helm_installed() {
    local HELM_VERSION="v3.8.0"  # Specify the desired Helm version

    if command -v helm >/dev/null 2>&1; then
        echo "Helm is already installed. Version: $(helm version --short)"
    else
        echo "Helm is not installed. Proceeding with installation..."

        HELM_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
        TEMP_SCRIPT="/tmp/get_helm.sh"

        echo "Downloading Helm installation script..."
        if curl -fsSL -o "$TEMP_SCRIPT" "$HELM_INSTALL_SCRIPT_URL"; then
            echo "Helm installation script downloaded successfully."
        else
            echo "Error: Failed to download Helm installation script."
            return 1
        fi

        echo "Making the installation script executable..."
        if chmod 700 "$TEMP_SCRIPT"; then
            echo "Installation script permissions set to executable."
        else
            echo "Error: Failed to set executable permissions on the installation script."
            return 1
        fi

        echo "Installing Helm version $HELM_VERSION..."
        if "$TEMP_SCRIPT" --version "$HELM_VERSION"; then
            echo "Helm $HELM_VERSION installed successfully. Version: $(helm version --short)"
        else
            echo "Error: Helm installation failed."
            return 1
        fi

        echo "Cleaning up..."
        rm -f "$TEMP_SCRIPT"
        echo "Installation script removed."
    fi
}

# Function to display a separator
separator() {
    echo "----------------------------------------"
}

# Function to prompt for input with a message and optional link
prompt_input() {
    local var_name="$1"
    local prompt_message="$2"
    local link="$3"
    echo
    echo "$prompt_message"
    if [ -n "$link" ]; then
        echo "For more information, visit: $link"
    fi
    read -p "$var_name: " "$var_name"
}

# install helm 
ensure_helm_installed

# Create the .ignored directory if it doesn't exist
mkdir -p .ignored

# GitHub App Private Key File
GITHUB_APP_PRIVATE_KEY_FILE=".ignored/github-app.private-key.pem"
echo "Your GitHub App Private Key file should be placed at: $GITHUB_APP_PRIVATE_KEY_FILE"
echo "If you haven't downloaded it yet, you can generate it from your GitHub App settings:"
echo "https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app#generating-a-private-key"
read -p "Press Enter once you have placed the private key file in the specified location..."

# Check if the private key file exists
if [ ! -f "$GITHUB_APP_PRIVATE_KEY_FILE" ]; then
    echo "Private key file not found at $GITHUB_APP_PRIVATE_KEY_FILE."
    echo "Please place your GitHub App private key at this location and rerun the script."
    exit 1
fi

echo "=== Setup Environment Variables ==="
separator

echo "This script will guide you through setting up the required environment variables."
echo "Please ensure you have the necessary permissions and access rights before proceeding."

separator

echo "=== GitHub Configuration ==="
separator

# GitHub App ID
prompt_input "GITHUB_APP_APP_ID" \
    "Enter your GitHub App ID:" \
    "123456" \
    "https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app"

# GitHub Client ID
prompt_input "GITHUB_APP_CLIENT_ID" \
    "Enter your GitHub App Client ID:" \
    "abcdef123456" \
    "https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app#where-can-i-find-my-client-id-and-client-secret"

# GitHub Client Secret
prompt_input "GITHUB_APP_CLIENT_SECRET" \
    "Enter your GitHub App Client Secret:" \
    "your-client-secret" \
    "https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app#where-can-i-find-my-client-id-and-client-secret"

# GitHub Organization
prompt_input "GITHUB_ORG" \
    "Enter your GitHub Organization Name (e.g., tosinsdeveloperhub):" \
    "tosinsdeveloperhub" \
    "https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/about-organizations"

# GitHub Organization URL
prompt_input "GITHUB_ORG_URL" \
    "Enter your GitHub Organization URL (e.g., https://github.com/tosinsdeveloperhub):" \
    "https://github.com/tosinsdeveloperhub" \
    "https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/about-organizations"

# GitHub App Webhook URL
prompt_input "GITHUB_APP_WEBHOOK_URL" \
    "Enter your GitHub App Webhook URL (e.g., https://your-cluster-domain/):" \
    "https://your-cluster-domain/" \
    "https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks"

# GitHub App Webhook Secret
prompt_input "GITHUB_APP_WEBHOOK_SECRET" \
    "Enter your GitHub App Webhook Secret:" \
    "rhdh-secret" \
    "https://docs.github.com/en/developers/webhooks-and-events/securing-your-webhooks"

separator

echo "=== Quay Configuration ==="
separator

# Quay Organization
prompt_input "QUAY_ORG" \
    "Enter your Quay Organization Name:" \
    "your-quay-org" \
    "https://quay.io/organization"

# Quay User
prompt_input "QUAY_USER" \
    "Enter your Quay Username:" \
    "a-quay-user-name" \
    "https://quay.io/signin/"

# Quay Token
prompt_input "QUAY_TOKEN" \
    "Enter your Quay OAuth Token (with admin permissions):" \
    "your-quay-oauth-token" \
    "https://quay.io/settings/"

separator

echo "=== Additional Configuration ==="
separator

# Read the private key content
GITHUB_PRIVATE_KEY=$(< "$GITHUB_APP_PRIVATE_KEY_FILE")

# Define fixed or derived values
QUAY_SERVER_URL="https://quay.io"

# Create the env.sh file with the provided inputs
cat > .ignored/env.sh <<EOF
#!/bin/bash
# Environment variables generated by setup_env.sh

export GITHUB_APP_APP_ID="${GITHUB_APP_APP_ID}"
export GITHUB_APP_CLIENT_ID="${GITHUB_APP_CLIENT_ID}"
export GITHUB_APP_CLIENT_SECRET="${GITHUB_APP_CLIENT_SECRET}"
export GITHUB_APP_PRIVATE_KEY_FILE="${GITHUB_APP_PRIVATE_KEY_FILE}"
export GITHUB_PRIVATE_KEY="${GITHUB_PRIVATE_KEY}"
export GITHUB_ORG="${GITHUB_ORG}"
export GITHUB_ORG_URL="${GITHUB_ORG_URL}"
export GITHUB_APP_WEBHOOK_URL="${GITHUB_APP_WEBHOOK_URL}"
export GITHUB_APP_WEBHOOK_SECRET="${GITHUB_APP_WEBHOOK_SECRET}"
export QUAY_SERVER_URL="${QUAY_SERVER_URL}"
export QUAY_ORG="${QUAY_ORG}"
export QUAY_USER="${QUAY_USER}"
export QUAY_TOKEN="${QUAY_TOKEN}"
EOF

# Secure the env.sh file
chmod 600 .ignored/env.sh

echo
echo "Environment file '.ignored/env.sh' has been created successfully."
echo "To load the environment variables, run:"
echo "  source .ignored/env.sh"
echo
echo "=== Setup Complete ==="
separator
echo "Recommendations:"
echo "- Ensure that the '.ignored' directory is added to your .gitignore to prevent sensitive information from being committed."
echo "  You can add it by running: echo '.ignored/' >> .gitignore"
echo "- Keep your private key and tokens secure. Avoid sharing them or committing them to version control."
echo "- Consider using secret management tools for enhanced security in production environments."
separator

# Secure the env.sh file
chmod 600 .ignored/env.sh

echo
echo "Environment file '.ignored/env.sh' has been created successfully."
echo "To load the environment variables, run:"
echo "  source .ignored/env.sh"
echo "  ansible-playbook ansible-automation/playbooks/vault-setup/main.yaml"
echo "  ansible-playbook ansible-automation/playbooks/rhdh-install/main.yaml"
