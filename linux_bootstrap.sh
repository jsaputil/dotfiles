#!/bin/bash

# Define variables
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/jsapjoni/dotfiles.git"

# Updating apt repositories
sudo apt update -y && sudo apt upgrade -y

# Installing flatpak as an additional package manager
sudo apt install flatpak -y && sudo apt install plasma-discover-backend-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Check if curl is installed
if ! command -v curl &> /dev/null
then
    # If not installed, install curl
    sudo apt update
    sudo apt install curl -y
    echo "curl has been installed."
else
    # If installed, provide feedback
    echo "curl is already installed."
fi

if ! command -v neofetch &> /dev/null
then
    # If not installed, install curl
    sudo apt update
    sudo apt install neofetch -y
    echo "neofetch has been installed."
else
    # If installed, provide feedback
    echo "neofetch is already installed."
fi

# Install git
if ! command -v git &> /dev/null
then
    # If not installed, install git
    sudo apt update
    sudo apt install git -y
    echo "Git has been installed."
else
    # If installed, provide feedback
    echo "Git is already installed."
fi

# Check if dotfiles directory exists
if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles repository already cloned."
else
    # Clone dotfiles repository
    git clone "$REPO_URL" "$DOTFILES_DIR" && echo "Dotfiles repository cloned." || echo "Failed to clone dotfiles repository."
fi

# Setting up Zsh as main shell
if ! command -v zsh &> /dev/null; then
    # If not installed, install Zsh
    sudo apt update
    sudo apt install zsh -y
    sudo chsh -s /bin/zsh
    echo "Zsh has been installed."
else
    # If installed, provide feedback
    echo "Zsh is already installed."
fi

# Symlink .zshrc
if [ -f "~/dotfiles/linux/.zshrc" ]; then
    # Check if .zshrc exists
    if [ -f "~/.zshrc" ]; then
        # If .zshrc exists in home directory, remove it
        rm "~/.zshrc"
        echo "Removed existing $HOME/.zshrc"
    fi
    
    # Create symlink
    ln -s "~/dotfiles/linux/.zshrc" "~/.zshrc" --force
    echo "Linked ~/dotfiles/linux/.zshrc to ~/.zshrc"
else
    echo "~/dotfiles/linux/.zshrc not found. Please ensure it exists."
fi

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # If Oh My Zsh is not installed, install it without prompting to change shell
    echo "Oh My Zsh is not installed. Installing..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    # If Oh My Zsh is installed, provide feedback
    echo "Oh My Zsh is already installed."
fi

# Define an array of plugin repositories
plugins=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

# Iterate over the plugins array
for plugin in "${plugins[@]}"; do
    # Extract plugin name from the repository URL
    plugin_name=$(basename "$plugin")
    plugin_name=${plugin_name%%.*} 

    # Check if the plugin is already installed
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name" ]; then
        echo "$plugin_name plugin is not installed. Installing..."
        git clone "$plugin" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    else
        echo "$plugin_name plugin is already installed."
    fi
done

# Setting up all desktop and terminal applications using flatpak.
declare -A apps=(
	["org.mozilla.firefox"]="firefox"
	["io.neovim.nvim"]="nvim"
  ["org.wezfurlong.wezterm"]="wezterm"
)

for app_id in "${!apps[@]}"; do
	alias_name=${apps[$app_id]}
	echo "Installing $app_id with alias $alias_name..."
	flatpak install -y "$app_id"

  if ! grep -q "alias $alias_name='flatpak run $app_id'" ~/.zshrc; then
      echo "alias $alias_name='flatpak run $app_id'" >> ~/.zshrc
  else
      echo "Alias for $alias_name already exists in .zshrc. Skipping..."
  fi
done

echo "All Flatpak applications installed. Please run 'source ~/.bashrc' to active aliases"

# Check if Neovim is installed via Flatpak
if flatpak list | grep -q 'org.vim.Neovim'; then
    # Create symlink for Neovim configuration
    ln -sf ~/dotfiles/common/neovim/neovim ~/.var/app/org.vim.Neovim/config/nvim --force
    echo "Neovim configuration symlinked."
else
    echo "Neovim is not installed via Flatpak."
fi

# Installing starship.rs terminal prompt
# Download the Starship binary
if command -v starship >/dev/null 2>&1; then
    echo "Starship is already installed. Skipping installation."
else
    echo "Starship not found. Proceeding with installation."

    # Download the Starship binary
    curl -L -o /tmp/starship.tar.gz https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz

    # Extract it to /usr/local/bin
    sudo tar xzf /tmp/starship.tar.gz -C /usr/local/bin

    # Make sure the binary is executable
    sudo chmod +x /usr/local/bin/starship

    echo "Starship installed successfully."

    # Clean up
    rm /tmp/starship.tar.gz
fi

# Optionally, add the init command to your shell config file
# Check if the init command is already in the file to avoid duplication
if ! grep -q 'eval "\$(starship init zsh)"' ~/.zshrc; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    echo "Starship initialization added to .zshrc."
else
    echo "Starship initialization already present in .zshrc."
fi

# Remove existing symlink for starship.toml if it exists
if [ -L "/home/jsaputil/.config/starship.toml" ]; then
    rm /home/jsaputil/.config/starship.toml
    echo "Removed existing symlink for starship.toml"
fi

# Create symlink for starship.toml
ln -s ~/dotfiles/common/starship/starship.toml ~/.config/starship.toml --force
echo "Created symlink for starship.toml"

# Download nerd-fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts

# Assuming WezTerm is already installed by this point in the script
SOURCE_CONFIG="$HOME/dotfiles/linux/wezterm/wezterm.lua"
TARGET_CONFIG="$HOME/.var/app/org.wezfurlong.wezterm/config/wezterm/wezterm.lua"

# Ensure the target directory exists
mkdir -p "$(dirname "$TARGET_CONFIG")"

# Remove existing config file or symlink to avoid errors on symlink creation
rm -f "$TARGET_CONFIG"

# Create a symlink to your custom configuration
ln -s "$SOURCE_CONFIG" "$TARGET_CONFIG" --force

echo "WezTerm configuration is symlinked to $SOURCE_CONFIG"

# Uninstall firefox-esr
PACKAGE="firefox-esr"

# Check if Firefox ESR is installed using apt list and grep
if apt list --installed 2>/dev/null | grep -q "^$PACKAGE/"; then
    echo "$PACKAGE is installed. Proceeding with uninstallation."

    # Uninstall Firefox ESR completely, including its configuration files and unneeded dependencies
    sudo apt purge $PACKAGE -y
    sudo apt autoremove -y

    echo "$PACKAGE has been completely uninstalled."
else
    echo "$PACKAGE is not installed."
fi

sudo reboot
