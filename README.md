# Dotfiles

Declarative, reproducible development environment across NixOS, macOS (nix-darwin), and WSL (home-manager standalone).

## What's included

**Shared across all platforms** (via home-manager):

- **Fish shell** with starship prompt, zoxide, autojump, AI functions, and custom keybindings
- **Tmux** with Ctrl-a prefix, vim navigation, sesh session switching, everforest theme, resurrect/continuum
- **Neovim** (LazyVim) with LSPs (Nix, Lua, TypeScript, Terraform), CodeCompanion (Claude), vim-dadbod, rustaceanvim
- **Git** with lazygit, diff-so-fancy, GitHub CLI (ssh)
- **CLI tools**: ripgrep, fd, fzf, bat, eza, jq, httpie, atuin, and more
- **Dev tools**: direnv + nix-direnv (per-project environments), rustup, awscli2, terraform-ls, vault, docker-compose, colima

**NixOS-specific**: GNOME desktop, PipeWire audio, PostgreSQL, MySQL, Redis, Memcached, Nginx, Docker, Tailscale, OpenSSH

**macOS-specific**: Dock/Finder/keyboard defaults, Homebrew casks (Ghostty, WezTerm, Raycast, DB Browser for SQLite)

## Prerequisites

### Nix (macOS and WSL)

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

NixOS has Nix built in — just ensure flakes are enabled (already configured in `nixos/configuration.nix`).

## Setup

Clone the repo:

```bash
git clone <repo-url> ~/Projects/dotfiles
cd ~/Projects/dotfiles
```

Edit `local.nix` with your machine-specific values (hostname, username, paths):

```bash
$EDITOR local.nix
```

Then tell git to ignore your local changes so they don't get committed:

```bash
git update-index --skip-worktree local.nix
```

### NixOS

1. Generate hardware config for a new machine:

```bash
sudo nixos-generate-config --show-hardware-config > nixos/hardware-configuration.nix
```

2. Stage and apply:

```bash
git add -A
sudo nixos-rebuild switch --flake .#nixos
```

### macOS (nix-darwin)

1. First time — bootstrap nix-darwin:

```bash
git add -A
nix run nix-darwin -- switch --flake .#mac
```

2. Subsequent rebuilds:

```bash
darwin-rebuild switch --flake .#mac
```

Homebrew casks are applied automatically during `darwin-rebuild`. No separate `brew bundle` needed.

### WSL (home-manager standalone)

1. First time:

```bash
git add -A
nix run home-manager/master -- switch --flake .#wsl
```

2. Subsequent rebuilds:

```bash
home-manager switch --flake .#wsl
```

## Per-machine customization

All machine-specific values live in `local.nix`. Edit it per machine and run `git update-index --skip-worktree local.nix` to prevent accidental commits:

```nix
{
  hostname = "my-machine";           # NixOS networking.hostName
  username = "hyb175";               # Unix username
  homeDirectory = "/home/hyb175";    # macOS: /Users/hyb175
  extraFishPaths = [
    # "/opt/homebrew/opt/mysql-client@8.0/bin"
  ];
  financeBroker = { enable = false; /* ... */ };
}
```

See `local.nix.example` for all available options with comments.

## Post-install

### Secrets

Create `~/.config/fish/secrets.fish` for API keys (not version controlled):

```fish
set -gx OPENAI_API_KEY "..."
set -gx ANTHROPIC_API_KEY "..."
```

```bash
chmod 600 ~/.config/fish/secrets.fish
```

### Docker (macOS/WSL)

```bash
colima start --cpu 4 --memory 8
docker ps
```

On NixOS, Docker runs as a system service automatically.

## Updating

```bash
cd ~/Projects/dotfiles

# Update flake inputs (nixpkgs, home-manager, nix-darwin)
nix flake update

# Then rebuild for your platform
sudo nixos-rebuild switch --flake .#nixos    # NixOS
darwin-rebuild switch --flake .#mac          # macOS
home-manager switch --flake .#wsl            # WSL
```

Update Neovim plugins separately:

```
:Lazy update
```

## Structure

```
dotfiles/
├── flake.nix                    # Entry point — defines nixos, mac, wsl targets
├── flake.lock
├── local.nix                    # Machine-specific overrides (edit per machine)
├── local.nix.example            # Documented template showing all options
├── nixos/
│   ├── configuration.nix        # NixOS system config (boot, GNOME, audio, etc.)
│   ├── hardware-configuration.nix
│   └── modules/
│       ├── system-packages.nix  # git, jujutsu, nodejs, python3, build tools
│       ├── services.nix         # PostgreSQL, MySQL, Redis, Nginx, Docker, Tailscale
│       ├── users.nix
│       └── finance-broker.nix   # Custom systemd service
├── darwin/
│   ├── configuration.nix        # macOS system defaults, fonts, fish
│   └── modules/
│       ├── system-packages.nix  # Mirrors NixOS core packages
│       └── homebrew.nix         # GUI casks (Ghostty, WezTerm, Raycast)
├── home-manager/
│   ├── home.nix                 # Shared packages across all platforms
│   └── modules/
│       ├── fish.nix             # Shell, aliases, autojump, per-machine paths
│       ├── tmux.nix             # Tmux config and plugins
│       ├── neovim.nix           # Neovim + LSPs + formatters
│       ├── git.nix              # Git, GitHub CLI, lazygit
│       ├── starship.nix         # Prompt config
│       └── development.nix      # direnv, rustup
├── nvim/                        # Neovim config (LazyVim, managed by lazy.nvim)
│   ├── init.lua
│   ├── lua/config/
│   └── lua/plugins/
├── fish/
│   ├── functions/               # Custom fish functions
│   └── conf.d/                  # fish_ai plugin config
└── starship.toml                # Starship prompt theme
```

## Key bindings

### Tmux (prefix: Ctrl-a)

| Key | Action |
|---|---|
| `\|` | Split horizontal |
| `-` | Split vertical |
| `h/j/k/l` | Navigate panes |
| `H/J/K/L` | Resize panes |
| `o` | Session switcher (sesh + fzf) |
| `S` | New session |
| `X` | Kill session, switch to last |
| `r` | Reload config |
| `Tab` | Cycle panes |

### Fish shell

| Alias | Command |
|---|---|
| `lg` | lazygit |
| `ll` | eza -l |
| `ta` | tmux attach |
| `vim` | nvim |

### Neovim

Leader key: `,`

See `nvim/lua/config/keymaps.lua` and LazyVim defaults.

## Maintenance

```bash
# Garbage collect old generations
sudo nix-collect-garbage -d   # NixOS
nix-collect-garbage -d        # macOS/WSL

# Rollback
sudo nixos-rebuild switch --rollback          # NixOS
darwin-rebuild switch --rollback               # macOS
home-manager generations                       # WSL — list, then:
home-manager switch --flake .#wsl --switch-generation <n>

# Check store size
du -sh /nix/store
```

## Troubleshooting

**"path not tracked by git"** — Flakes require files to be staged: `git add -A`

**Package not found** — Search nixpkgs: `nix search nixpkgs <name>`

**Service won't start (NixOS)** — Check logs: `journalctl -u <service> -f`

**`git pull` conflicts with `local.nix`** — If upstream changes `local.nix`, you'll need to temporarily undo skip-worktree, stash your changes, pull, then restore:

```bash
git update-index --no-skip-worktree local.nix
git stash
git pull
git stash pop
git update-index --skip-worktree local.nix
```
