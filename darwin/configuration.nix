{ config, pkgs, localConfig, self, ... }:

{
  imports = [
    ./modules/system-packages.nix
    ./modules/homebrew.nix
    ./modules/aerospace.nix
  ];

  users.users.${localConfig.username} = {
    name = localConfig.username;
    home = localConfig.homeDirectory;
  };

  # Required by nix-darwin for user-scoped system.defaults and homebrew activation
  system.primaryUser = localConfig.username;

  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Set outside fish too, so non-fish contexts (git, sudoedit, cron) agree.
  environment.variables.EDITOR = "nvim";

  # nix-darwin defaults this to 30000 below stateVersion 5; the modern
  # installer creates the group as 350.
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

      wvous-tl-corner = 2;   # top-left     — Mission Control
      wvous-tr-corner = 13;  # top-right    — Lock Screen
      wvous-bl-corner = 3;   # bottom-left  — Application Windows
      wvous-br-corner = 4;   # bottom-right — Desktop
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
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
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
    material-design-icons
    font-awesome
  ];

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # programs.fish.enable does not register fish in /etc/shells, so `chsh` to it
  # is rejected without this.
  environment.shells = [ pkgs.fish ];

  programs.zsh.enable = false;
  programs.bash.enable = false;

  security.pam.services.sudo_local.touchIdAuth = true;

  # Used for backwards compatibility
  system.stateVersion = 4;
}
