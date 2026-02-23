{ config, pkgs, ... }:

{
  imports = [
    ./modules/system-packages.nix
    ./modules/homebrew.nix
  ];

  # Enable nix-darwin
  services.nix-daemon.enable = true;

  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  # nixpkgs config
  nixpkgs.config.allowUnfree = true;

  # macOS system settings
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
    };

    # Global settings
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Used for backwards compatibility
  system.stateVersion = 4;
}
