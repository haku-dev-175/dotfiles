{ config, pkgs, lib, localConfig, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./configuration-base.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking (bare-metal)
  networking.networkmanager.enable = true;

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

  # Firefox
  programs.firefox.enable = true;

  # Intel thermal management (throttle before fans ramp up)
  services.thermald.enable = true;

  # Disable hibernation
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
