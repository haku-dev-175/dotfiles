{ config, pkgs, ... }:

{
  # Homebrew configuration (GUI apps only)
  homebrew = {
    enable = true;

    # Automatically update Homebrew and cleanup old versions
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    # GUI Applications (Casks) - things not available in nixpkgs
    casks = [
      # "docker"                     # Docker Desktop (optional - can use colima from Nix instead)
      "ghostty"                      # Terminal emulator
      "wezterm"                      # Terminal emulator
      "raycast"                      # Spotlight replacement
      "db-browser-for-sqlite"       # SQLite browser
    ];

    # Mac App Store apps (optional)
    # masApps = {
    #   "1Password" = 1333542190;
    # };
  };
}
