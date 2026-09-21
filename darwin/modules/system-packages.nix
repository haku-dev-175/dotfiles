{ config, pkgs, ... }:

{
  # System-wide packages for macOS
  environment.systemPackages = with pkgs; [
    # Core utilities
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
  ];
}
