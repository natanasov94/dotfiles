#!/bin/bash

# Show usage if no argument
if [ $# -eq 0 ]; then
    echo "Usage: source /tmp/dotfiles/bootstrap.sh [python|java|ts|all]"
    return 0
fi

# Store requested modules
MODULES=("$@")

# I intend to use this for devcontainers
export TERM=xterm-256color

# --- Base package install ---

apt-get update
apt-get install -y \
    curl \
    git \
    zip \
    unzip \
    wget \
    tmux \
    starship \
    gcc \
    tree-sitter-cli

mkdir -p ~/.config

# --- Neovim ---
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
		rm -rf /opt/nvim-linux-x86_64 && \
		tar -C /opt -xzf nvim-linux-x86_64.tar.gz

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
# Should i just install it in /usr/local/bin instead of how the installer does it? (shrugs)
ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin

# --- Bash ---
cp /tmp/dotfiles/arch/.bashrc ~/.bashrc

# --- Tmux ---
cp -r /tmp/dotfiles/nvim ~/.config/nvim
cp /tmp/dotfiles/tmux/.tmux.conf ~/.tmux.conf
# --- Tmux theme ---
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

# --- Starship ---
cp /tmp/dotfiles/arch/starship.toml ~/.config/starship.toml

# --- LSP functions for nvim --
install_python() {
    apt-get install -y \
        python3 \
        python3-pip

    pip install --break-system-packages \
        pyright \
        black
}

install_ts() {
    apt-get install -y \
        nodejs \
        npm

    npm install -g \
        typescript \
        typescript-language-server \
        prettier
}
install_java() {
    curl -s "https://get.sdkman.io" | bash
}

# --- Install modules ---
for module in "${MODULES[@]}"; do
    case "$module" in
        python) install_python ;;
        java)   install_java ;;
        ts)     install_ts ;;
        all)    install_python; install_java; install_ts ;;
        *)
            echo "Unknown module: $module"
            exit 1
            ;;
    esac
done

# Preload all plugins in nvim
nvim --headless +Lazy! +qa
