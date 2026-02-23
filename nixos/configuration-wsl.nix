{ config, pkgs, lib, localConfig, ... }:

{
  imports = [
    ./configuration-base.nix
  ];

  wsl = {
    enable = true;
    defaultUser = localConfig.username;
  };
}
