#!/bin/bash

######################################################
#
#  THIS CONFIG IS USED FOR SIMPLER ENVIRONMENTS
#
######################################################

# Define variables
DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/jsaputil/dotfiles.git"

# Updating apt repositories
sudo apt update -y && sudo apt upgrade -y
mkdir -p ~/.config

# Check if curl is installed
if ! command -v curl &>/dev/null; then
	# If not installed, install curl
	sudo apt update
	sudo apt install curl -y
	echo "curl has been installed."
else
	# If installed, provide feedback
	echo "curl is already installed."
fi

if ! command -v neofetch &>/dev/null; then
	# If not installed, install curl
	sudo apt update
	sudo apt install neofetch -y
	echo "neofetch has been installed."
else
	# If installed, provide feedback
	echo "neofetch is already installed."
fi

# Install git
if ! command -v git &>/dev/null; then
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
if ! command -v zsh &>/dev/null; then
	# If not installed, install Zsh
	sudo apt update
	sudo apt install zsh -y
	sudo chsh -s /bin/zsh
	echo "Zsh has been installed."
else
	# If installed, provide feedback
	echo "Zsh is already installed."
fi

# Setting up Neovim as main editor
if ! command -v neovim &>/dev/null; then
	# If not installed, install neovim
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	sudo mv nvim.appimage /usr/local/bin/nvim
	sudo ln -s /usr/local/bin/nvim /usr/bin/nvim
	sudo apt install build-essential
	echo "neovim has been installed."
else
	# If installed, provide feedback
	echo "neovim is already installed."
fi

# Symlink .zshrc
if [ -f "~/.dotfiles/linux/.zshrc" ]; then
	# Check if .zshrc exists
	if [ -f "~/.zshrc" ]; then
		# If .zshrc exists in home directory, remove it
		rm "~/.zshrc"
		echo "Removed existing $HOME/.zshrc"
	fi

	# Create symlink
	ln -s "~/.dotfiles/linux/.zshrc" "~/.zshrc" --force
	echo "Linked ~/.dotfiles/linux/.zshrc to ~/.zshrc"
else
	echo "~/.dotfiles/linux/.zshrc not found. Please ensure it exists."
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
	echo 'eval "$(starship init zsh)"' >>~/.zshrc
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
ln -s ~/.dotfiles/common/starship/starship.toml ~/.config/starship.toml --force
echo "Created symlink for starship.toml"

# Download nerd-fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts

# Symlink neovim config directory
if [ -d "~/.dotfiles/common/neovim/neovim" ]; then
	# Create symlink
	ln -sd "~/.dotfiles/common/neovim/neovim*" "~/.config/nvim" --force
	echo "Linked ~/.dotfiles/common/neovim/neovim to ~/.config/nvim"
else
	echo "~/.dotfiles/common/neovim/neovim directory not found. Please ensure it exists."
fi

