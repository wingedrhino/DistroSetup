mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/pnpm-store
corepack enable --install-directory=$HOME/.local/bin
corepack prepare pnpm@latest --activate
pnpm config set store-dir $HOME/.local/pnpm-store

