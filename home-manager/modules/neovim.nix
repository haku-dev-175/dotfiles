{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # Pinned explicitly: home-manager flipped these defaults to false in 26.05
    # and warns while home.stateVersion is older. Set false to slim the closure
    # if no plugin needs the Ruby/Python remote-plugin providers.
    withRuby = true;
    withPython3 = true;

    # System packages for Neovim/plugins
    extraPackages = with pkgs; [
      # LSP servers
      nil  # Nix LSP
      lua-language-server
      typescript-language-server
      vscode-langservers-extracted
      terraform-ls

      # Formatters
      prettier
      stylua

      # Tools
      tree-sitter
      nodejs  # needed by tree-sitter CLI
      ripgrep
      fd

      # Build tools for native plugins
      gcc
      gnumake
      cmake
      lua5_1
      luarocks
    ];
  };

  # Symlink existing Neovim config files individually
  # This allows lazy-lock.json to be writable by LazyVim
  xdg.configFile = {
    "nvim/init.lua".source = ../../nvim/init.lua;
    "nvim/lazyvim.json".source = ../../nvim/lazyvim.json;
    "nvim/stylua.toml".source = ../../nvim/stylua.toml;
    "nvim/.neoconf.json".source = ../../nvim/.neoconf.json;
    "nvim/lua" = {
      source = ../../nvim/lua;
      recursive = true;
    };
  };
}
