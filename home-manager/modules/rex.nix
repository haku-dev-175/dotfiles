# Rex terminal multiplexer + personal server (systemd user service).
# Imported only on the NixOS host (see flake.nix); services.rex is Linux-only.
# Linger is already on for this account, so the server survives logout.
# After an update, `systemctl --user restart rex` (switch keeps the old one).
{ ... }:

{
  programs.rex.enable = true;
  services.rex.enable = true;

  # Rex's ssh guard goes into ~/.ssh/config, which home-manager only writes
  # with programs.ssh on, so the hand-written config is ported here.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # Default GitHub account (hyb175)
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      # Dedicated alias for the haku-dev-175 GitHub account
      "github-haku" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_haku";
        identitiesOnly = true;
      };
    };
  };
}
