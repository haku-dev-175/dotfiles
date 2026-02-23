{ config, pkgs, localConfig, ... }:

{
  users.users.${localConfig.username} = {
    isNormalUser = true;
    home = localConfig.homeDirectory;
    description = localConfig.username;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
  };
}
