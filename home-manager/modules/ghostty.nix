# Ghostty config only. The app itself comes from the Homebrew cask on macOS
# (darwin/modules/homebrew.nix), so package is null and home-manager writes
# nothing but ~/.config/ghostty/config. Shell integration is left alone:
# Ghostty injects its own when it launches the shell.
{ config, pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;
    package = null;
    # package = null means there is no unit to run, but the option defaults to
    # true on Linux and the module asserts on the pair.
    systemd.enable = false;

    settings = {
      # tide's prompt and the tmux status line are built from Nerd Font
      # glyphs. Ghostty's default font has none of them, so every icon
      # renders as a replacement box until this is set. Name is as
      # `ghostty +list-fonts` reports it, which is what the config parser
      # matches against.
      font-family = "JetBrainsMono Nerd Font Mono";
      font-size = 13;

      # Matches the everforest palette the tmux status line uses. Ghostty
      # ships no Dark Medium variant, so this is a shade darker than tmux's
      # #2d353b background.
      theme = "Everforest Dark Hard";
    };
  };
}
