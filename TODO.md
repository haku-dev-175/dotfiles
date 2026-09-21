# TODO

Remaining deltas against `../dotfiles-alt`, whose nested `nix/nix-darwin/` tree
is an older generation this repo was refactored away from. Paths cited are in
that repo.

Already ported: fish in `/etc/shells`, `docker-client`, `autojump`,
`mysql-client` on PATH, TouchID sudo, `brew shellenv`, system-wide `EDITOR`,
`programs.eza`, `configurationRevision`, AeroSpace, the macOS defaults (hot
corners, Finder pathbar/statusbar/POSIX title), the icon and Nerd fonts,
`terraform`/`k9s`/`helmfile`/`kubectl`/`yazi`/`glow`, and the tmux session
scripts.

Declined: `reviewdog`, `taskwarrior2`, `xcbeautify`, `swiftlint`, `unbound`,
`dfu-util`, and `asdf-vm` (superseded by mise, installed via brew and activated
in `~/.zshrc`).

## Homebrew

- [ ] **Prune formulae now duplicated by Nix.** Nix owns `kubectl` as of this
      round, so brew's `kubernetes-cli` is redundant; `awscli`, `gh`, `gnupg`,
      `git` and `coreutils` are likewise duplicated. They are shadowed rather
      than broken — fish puts brew behind Nix on PATH — so this is tidying, not
      a fix. `asdf` and `pinentry-mac` have no Nix equivalent here; leave them.
- [ ] Casks — `flipper` (mobile debugging), `keybase`, `insomnia` (HTTP client),
      `font-sauce-code-pro-nerd-font`. See `darwin/modules/homebrew.nix` and
      `homebrew/Brewfile`.
- [ ] `masApps` — `Xcode` (497799835), `Wechat` (836500024)
      (`nix/nix-darwin/modules/packages.nix:20-24`). Each app must have been
      installed manually once under the same Apple account first.

## Container runtime overlap

- [ ] **Docker Desktop is the active runtime on this machine**, and it is
      IT-provisioned: `/usr/local/bin/docker` 29.8.0, `credsStore: desktop`,
      `currentContext: desktop-linux`. The dotfiles also install `colima`
      ("lightweight alternative to Docker Desktop") and `docker-client`, so
      three sources now overlap. Nix's client is the same 29.8.0 and
      `docker-credential-desktop` stays on PATH, so nothing breaks — but
      `colima` has never been started here and the README's `colima start`
      would stand up a second daemon. Decide whether this machine keeps Docker
      Desktop, in which case `colima` and `docker-client` can come out of the
      darwin path, or moves to colima, in which case Docker Desktop should go.

## Automation

- [ ] **Port `install.sh` and `check.sh`** (5.3 KB / 5.0 KB at the alt repo
      root). This repo has no equivalent, which is why the macOS bootstrap was
      entirely hand-driven. A `check.sh` would have caught the `/etc/shells`,
      `docker` and `autojump` gaps without a rebuild.

## tmux

- [ ] **`dev-env.sh` is not ported.** It hardcodes
      `$HOME/mycase/{mycase_app,mycase_login}` and runs MyCase-specific puma
      (ports 3001/3002) and foreman commands. `~/mycase` does not exist on this
      machine. Either drop it or rewrite it around the current project layout —
      `dev-node.sh` shows the parameterised shape to follow.

## fish

- [ ] Remaining PATH extras from `nix/nix-darwin/home/shell.nix` — kubescape bin
      (`:46-48`) and the Android SDK `tools` dir (only `platform-tools` is added
      here).
- [ ] Aliases `kli` (`TERM=xterm-256color k9s`) and `nc` (edit the flake).
      `ls`/`ll` now come from `programs.eza`, so those two are already covered.

## Open question

- [ ] **`system.stateVersion`** — this repo pins `4`; alt's nested tree uses `6`,
      which is why alt never hit the nixbld GID mismatch. Bumping 4 → 5 would
      make `ids.gids.nixbld = 350` in `darwin/configuration.nix` redundant and
      changes nothing else in nix-darwin. Going to `6` also flips three
      `environment` defaults, so check those first. Note `home.stateVersion` is
      separate and still `24.05`, which is what makes home-manager warn about
      changed defaults (`programs.neovim.withRuby`, `programs.yazi
      .shellWrapperName`); both are now pinned explicitly.
