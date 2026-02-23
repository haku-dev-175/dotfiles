{ config, pkgs, machineConfig, ... }:

{
  imports = [
    ./modules/fish.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/starship.nix
    ./modules/development.nix
  ];

  home = {
    username = machineConfig.username;
    homeDirectory = machineConfig.homeDirectory;
    stateVersion = "24.05";

    # Packages without special config
    packages = with pkgs; [
      # Search & File Tools
      ripgrep fd fzf bat eza zoxide

      # Git ecosystem
      gh git-lfs lazygit diff-so-fancy

      # DevOps
      awscli2 terraform-ls vault docker-compose
      colima  # Docker runtime (lightweight alternative to Docker Desktop)

      # Tmux tools
      sesh tmuxinator

      # Utilities
      jq httpie atuin imagemagick gnupg certbot
      helix watchman

      # Clipboard (Linux)
      xclip wl-clipboard

      # Cloud Native
      pack  # Cloud Native Buildpacks

      # Networking
      dnsmasq

      # Messaging
      signal-cli

      # Additional tools
      gnutls openssl libfido2 krb5 qrencode

      # Nerd Fonts (for terminal icons)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
  };

  programs.home-manager.enable = true;
}
