{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
  ];

  # direnv for per-project Nix development environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };
}
