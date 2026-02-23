{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # System packages for Neovim/plugins
    extraPackages = with pkgs; [
      # LSP servers
      nil  # Nix LSP
      lua-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      terraform-ls

      # Formatters
      nodePackages.prettier
      stylua

      # Tools
      tree-sitter
      ripgrep
      fd

      # Build tools for native plugins
      gcc
      gnumake
      cmake
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
