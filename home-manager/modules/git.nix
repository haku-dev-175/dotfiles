{ config, pkgs, machineConfig, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = machineConfig.gitUserName;
        email = machineConfig.gitUserEmail;
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      core.pager = "diff-so-fancy | less --tabs=4 -RFX";

      # gh builds canonical git@github.com URLs, so a repo whose owner needs a
      # non-default SSH key is unreachable over ssh. Rewrite those onto the
      # ~/.ssh/config Host alias that carries the right key. Machine-local,
      # because the aliases live in an unmanaged ~/.ssh/config.
      url = builtins.mapAttrs (_: canonical: { insteadOf = canonical; })
        machineConfig.gitUrlRewrites;

      color = {
        ui = true;
        diff-highlight = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
      };

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".envrc"
      ".direnv"
      "result"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };

  programs.lazygit.enable = true;
}
