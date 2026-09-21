{ config, pkgs, machineConfig, ... }:

let
  # `pack completion` writes the script and prints its path. Generate it once at
  # build time rather than spawning pack on every interactive startup.
  packFishCompletions = pkgs.runCommand "pack-fish-completions" { } ''
    export HOME=$(mktemp -d)
    ${pkgs.pack}/bin/pack completion --shell fish > /dev/null
    cp "$HOME/.pack/completion.fish" $out
  '';
in
{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Set editor
      set -gx EDITOR nvim

      # Inlined `brew shellenv`, whose output is static — calling it cost ~29ms
      # of every startup. Appended rather than prepended so Nix stays ahead of
      # brew on PATH. brew's own MANPATH line only normalises an already-set
      # MANPATH, so there is nothing to reproduce for it.
      if test -d /opt/homebrew
          set -gx HOMEBREW_PREFIX /opt/homebrew
          set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
          set -gx HOMEBREW_REPOSITORY /opt/homebrew/Homebrew
          fish_add_path --global --move --append /opt/homebrew/bin /opt/homebrew/sbin
          set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
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
      # Buildpack CLI completion, generated at build time (see let block)
      source ${packFishCompletions}

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

  # autojump derives OSTYPE by spawning bash, costing ~10ms of every startup.
  # It is loaded from its own vendor_conf.d, i.e. before config.fish, so setting
  # this in shellInit is too late. conf.d is sourced in basename order across all
  # conf.d dirs, so 00- lands first. The value only feeds a darwin*/linux* glob.
  xdg.configFile."fish/conf.d/00-ostype.fish".text =
    "set -gx OSTYPE ${if pkgs.stdenv.hostPlatform.isDarwin then "darwin" else "linux-gnu"}\n";

  # Preserve any conf.d files
  xdg.configFile."fish/conf.d" = {
    source = ../../fish/conf.d;
    recursive = true;
  };
}
