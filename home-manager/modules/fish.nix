{ config, pkgs, machineConfig, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Set editor
      set -gx EDITOR nvim

      # shellenv also exports HOMEBREW_PREFIX, MANPATH and INFOPATH. It
      # prepends brew to PATH, so move it back behind Nix afterwards.
      if test -x /opt/homebrew/bin/brew
          eval (/opt/homebrew/bin/brew shellenv)
          fish_add_path --move --append /opt/homebrew/bin /opt/homebrew/sbin
      end

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
      # Buildpack CLI completion (if pack is available)
      if command -q pack
          source (pack completion --shell fish)
      end

      # Source secrets file
      if test -f ~/.config/fish/secrets.fish
          source ~/.config/fish/secrets.fish
      end
    '';

    # ls/ll come from programs.eza's fish integration below.
    shellAliases = {
      lg = "lazygit";
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

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    enableFishIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    # home-manager still defaults this to "yy" below stateVersion 26.05.
    shellWrapperName = "y";
    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  # Sources its integration from the store path; the previous hand-rolled
  # version only looked in homebrew and /usr/share, so it never fired.
  programs.autojump = {
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
