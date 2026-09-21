# TODO

Carried over from `dotfiles-alt`, which holds two generations: a top-level
`darwin/` + `home-manager/` layout this repo descends from, and an older nested
`nix/nix-darwin/` tree (`stateVersion = 6`, flake output `#me`). Nearly
everything below lives in that nested tree — features dropped in the refactor,
not new ideas. Paths cited are in `../dotfiles-alt`.

The four blocking gaps (fish not in `/etc/shells`, missing `docker` client,
uninstalled `autojump`, `mysql-client` off the fish PATH) are already fixed.

## Quality of life

- [ ] **TouchID for sudo** — `security.pam.services.sudo_local.touchIdAuth = true`
      (`nix/nix-darwin/modules/system.nix:71`). Would have saved most of the
      password prompts during this bootstrap.
- [ ] **Use `brew shellenv`** instead of bare PATH entries
      (`nix/nix-darwin/home/shell.nix:5`). `extraFishPaths` sets only PATH;
      `brew shellenv` also sets `HOMEBREW_PREFIX`, `MANPATH`, `INFOPATH`.
- [ ] **System-wide `EDITOR`** — `environment.variables.EDITOR = "nvim"`
      (`nix/nix-darwin/modules/packages.nix:4`). Currently set inside fish only,
      so it is unset for non-fish contexts.
- [ ] **`eza` as a program module** (`nix/nix-darwin/home/core.nix:57-62`) with
      `git = true`, icons and fish integration, replacing the bare package plus
      `ll` alias.
- [ ] **`system.configurationRevision`** (`system.nix:8`) — stamps the git rev
      into `darwin-version`, so `darwin-version` identifies the commit.

## Missing tools

All from `nix/nix-darwin/home/core.nix` unless noted.

- [ ] `terraform` — only `terraform-ls` (the language server) is installed; the
      CLI itself is absent.
- [ ] `k9s`, `helmfile` — Kubernetes TUI and helm orchestration.
- [ ] `kubectl` — currently comes from brew's `kubernetes-cli`. Decide whether
      Nix should own it instead.
- [ ] `glow` — terminal markdown previewer.
- [ ] `yazi` — terminal file manager, with fish integration
      (`core.nix:65-75`).
- [ ] `reviewdog`, `taskwarrior2` — from `dotfiles-alt/home-manager/home.nix`.
- [ ] `xcbeautify`, `swiftlint` — Swift/iOS tooling. Skip unless doing iOS work.
- [ ] `unbound`, `dfu-util` — DNS resolver and firmware flashing. Niche.
- [ ] `asdf-vm` — superseded by mise (installed via brew, activated in
      `~/.zshrc`). Likely drop rather than port.

## AeroSpace

- [ ] **Port `nix/nix-darwin/modules/aerospace.nix`** — a complete
      `services.aerospace` config: tiles layout, zero gaps, `alt-hjkl` focus,
      `alt-shift-hjkl` move, workspaces on `alt-1..9` and `alt-a..z`,
      `alt-tab` back-and-forth, and an `on-window-detected` rule forcing Ghostty
      to tiling. Drops in nearly as-is; needs the `aerospace` cask or package.

## macOS defaults

From `nix/nix-darwin/modules/system.nix:24-56`.

- [ ] Hot corners — `wvous-tl-corner` (Mission Control), `wvous-tr-corner`
      (Lock Screen), `wvous-bl-corner` (Application Windows), `wvous-br-corner`
      (Desktop).
- [ ] Finder — `ShowPathbar`, `ShowStatusBar`, `_FXShowPosixPathInTitle`.
- [ ] Fonts — `material-design-icons`, `font-awesome`,
      `nerd-fonts._0xproto`, `nerd-fonts.droid-sans-mono`.

## Homebrew

- [ ] Casks — `flipper` (mobile debugging), `keybase`, `insomnia` (HTTP client),
      `font-sauce-code-pro-nerd-font`. See `darwin/modules/homebrew.nix` and
      `homebrew/Brewfile`.
- [ ] `masApps` — `Xcode` (497799835), `Wechat` (836500024)
      (`nix/nix-darwin/modules/packages.nix:20-24`). Requires each app to have
      been installed manually once under the same Apple account.

## Automation

- [ ] **Port `install.sh` and `check.sh`** (5.3 KB / 5.0 KB at the alt repo
      root). This repo has no equivalent, which is why this bootstrap was
      entirely hand-driven. A `check.sh` would have caught the
      `/etc/shells`, `docker` and `autojump` gaps without a rebuild.

## tmux

- [ ] **Session scripts** — `tmux/scripts/dev-env.sh` (3-pane `mycase_app`
      layout: dev log tail, services, shell) and `tmux/scripts/dev-node.sh`.
      `sesh` and `tmuxinator` are installed but these layouts are not defined.

## Open questions

- [ ] **`system.stateVersion`** — this repo pins `4`; alt's nested tree uses
      `6`. That is why alt never hit the nixbld GID mismatch: its default was
      already 350. Bumping 4 → 5 would make `ids.gids.nixbld = 350` in
      `darwin/configuration.nix` redundant and changes nothing else. Going to
      `6` also flips three `environment` defaults, so check those first.
- [ ] **fish PATH extras from alt's `shell.nix`** — kubescape bin
      (`shell.nix:46-48`), Android SDK `tools` dir (only `platform-tools` is
      added here), and the `ls`/`l`/`kli`/`nc` aliases.
