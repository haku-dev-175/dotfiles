{ config, pkgs, localConfig, ... }:

{
  imports = [
    ./modules/system-packages.nix
    ./modules/homebrew.nix
  ];

  # The user nix-darwin and home-manager manage
  users.users.${localConfig.username} = {
    name = localConfig.username;
    home = localConfig.homeDirectory;
  };

  # Required by nix-darwin for user-scoped system.defaults and homebrew activation
  system.primaryUser = localConfig.username;

  # The modern Nix installer creates the nixbld group with GID 350, but
  # nix-darwin still defaults to the legacy 30000 at system.stateVersion 4.
  # Verified with `dscl . -read /Groups/nixbld PrimaryGroupID`.
  ids.gids.nixbld = 350;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Deduplicate the store on a schedule (auto-optimise-store can corrupt it)
  nix.optimise.automatic = true;

  # nixpkgs config
  nixpkgs.config.allowUnfree = true;

  # Package overrides (pinned pnpm, ...)
  nixpkgs.overlays = [ (import ../overlays/pnpm.nix) ];

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

  programs.zsh.enable = false;
  programs.bash.enable = false;

  # Used for backwards compatibility
  system.stateVersion = 4;
}
