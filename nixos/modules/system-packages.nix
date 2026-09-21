{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core utilities (system-wide)
    git
    jujutsu
    vim
    wget
    curl

    # Languages
    nodejs
    pnpm-pinned  # exact version pinned in overlays/pnpm.nix
    python3

    # Build essentials
    gcc
    gnumake
    cmake
    pkg-config
    coreutils

    # Browsers
    chromium
    playwright-test

    # System tools
    pciutils
    usbutils
  ];
}
