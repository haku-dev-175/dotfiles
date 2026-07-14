# Anthropic CLI (`ant`) — Claude API from the terminal.
# Not in nixpkgs yet; built from source with buildGoModule.
# To bump: update version + rev, refresh `hash` (nix flake prefetch
# github:anthropics/anthropic-cli/vX.Y.Z), then rebuild once with
# vendorHash = pkgs.lib.fakeHash and copy the "got:" hash from the error.
{ config, pkgs, ... }:

let
  anthropic-cli = pkgs.buildGoModule rec {
    pname = "anthropic-cli";
    version = "1.17.0";

    src = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "anthropic-cli";
      rev = "v${version}";
      hash = "sha256-uoD35oaeDf8opZSjzb7AHV0m0BKn7k3ujGGm9MARGws=";
    };

    vendorHash = "sha256-ZmxK6NrY+cqFf/BSm3Go7xQc/kEMO41oO82uSxNv3nw=";

    subPackages = [ "cmd/ant" ];
    doCheck = false;

    meta = with pkgs.lib; {
      description = "Anthropic CLI (ant) — drive the Claude API from the shell";
      homepage = "https://github.com/anthropics/anthropic-cli";
      mainProgram = "ant";
    };
  };
in
{
  home.packages = [ anthropic-cli ];
}
