# agent-fleet — tmux-native session manager for coding agents.
# The flake's package is a wrapper carrying its own tmux/bash/coreutils, so it
# works on a stock macOS (bash 3.2) without touching the host shell.
{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.agent-fleet.packages.${pkgs.stdenv.hostPlatform.system}.default

    # For the DEV CHECKOUT (~/Projects/agent-fleet), whose `#!/usr/bin/env bash`
    # needs bash >= 4 on PATH — the wrapper above only fixes its own copy.
    pkgs.bashInteractive
  ];
}
