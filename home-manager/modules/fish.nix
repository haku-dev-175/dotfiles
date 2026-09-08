{ config, pkgs, machineConfig, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Set editor
      set -gx EDITOR nvim

      # GPG TTY
      set -gx GPG_TTY (tty)

      # Android SDK (if needed)
      set -gx ANDROID_HOME $HOME/Library/Android/sdk/
      set -gx PATH $ANDROID_HOME/platform-tools $PATH

      # pnpm global bin. Appended, not prepended: pnpm is pinned in nix
      # (overlays/pnpm.nix), and a self-managed pnpm shim dropped in PNPM_HOME
      # would otherwise shadow it.
      set -gx PNPM_HOME $HOME/.local/share/pnpm
      fish_add_path --append $PNPM_HOME

      # Local bin
      set -gx PATH $HOME/.local/bin $PATH

      # Kimi Code (installed via upstream install script)
      if test -d $HOME/.kimi-code/bin
          fish_add_path --append $HOME/.kimi-code/bin
      end

      # Per-machine extra paths
      ${builtins.concatStringsSep "\n" (map (p: "fish_add_path --append ${p}") machineConfig.extraFishPaths)}
    '';

    interactiveShellInit = ''
      # Autojump
      if test -f /opt/homebrew/share/autojump/autojump.fish
          source /opt/homebrew/share/autojump/autojump.fish
      else if test -f /usr/share/autojump/autojump.fish
          source /usr/share/autojump/autojump.fish
      end

      # Buildpack CLI completion (if pack is available)
      if command -q pack
          source (pack completion --shell fish)
      end

      # Source secrets file
      if test -f ~/.config/fish/secrets.fish
          source ~/.config/fish/secrets.fish
      end
    '';

    shellAliases = {
      lg = "lazygit";
      ll = "eza -l";
      ta = "tmux attach";
      vim = "nvim";
    };

    functions = {
      fish_greeting = "";  # Disable greeting
    };
  };

  # Zoxide integration
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Preserve custom functions from fish/functions/
  xdg.configFile."fish/functions" = {
    source = ../../fish/functions;
    recursive = true;
  };

  # Preserve any conf.d files
  xdg.configFile."fish/conf.d" = {
    source = ../../fish/conf.d;
    recursive = true;
  };
}
