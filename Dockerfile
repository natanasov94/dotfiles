FROM debian:trixie-slim AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# ---- Base system ----
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    build-essential \
    ca-certificates \
    ripgrep \
    fd-find \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    lua5.4 \
    luarocks \
	gradle \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/natanasov94/dotfiles /tmp/dotfiles

# ---- Neovim ----
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
		rm -rf /opt/nvim-linux-x86_64 && \
		tar -C /opt -xzf nvim-linux-x86_64.tar.gz
ENV PATH="$PATH:/opt/nvim-linux-x86_64/bin"
RUN ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin
RUN mv /tmp/dotfiles/nvim /root/.config/nvim

# ---- Node / TS LSP ----
RUN npm install -g \
    typescript \
    typescript-language-server \
    prettier

# ---- Python LSP ----
RUN pip install --break-system-packages pyright

RUN curl -s "https://get.sdkman.io" | bash
COPY ./nvim /root/.config/nvim

CMD ["bash"]
