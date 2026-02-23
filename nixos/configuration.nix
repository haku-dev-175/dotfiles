{ config, pkgs, lib, localConfig, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system-packages.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/finance-broker.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = localConfig.hostname;
  networking.networkmanager.enable = true;
  networking.firewall.allowedUDPPorts = [ 41641 ];  # Tailscale

  # Timezone & Locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Financial broker — configured via local.nix
  services.finance-broker = lib.mkIf localConfig.financeBroker.enable {
    enable = true;
    binaryPath = localConfig.financeBroker.binaryPath;
    configFile = localConfig.financeBroker.configFile;
    secretSource = localConfig.financeBroker.secretSource;
  };

  # Firefox
  programs.firefox.enable = true;

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Enable nix-ld for running dynamically linked binaries (AppImages, etc.)
  programs.nix-ld.enable = true;

  # Enable Nix flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Intel thermal management (throttle before fans ramp up)
  services.thermald.enable = true;

  # Disable hibernation
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
