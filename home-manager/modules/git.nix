{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Yingbai He";
        email = "haku.dev@outlook.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      core.pager = "diff-so-fancy | less --tabs=4 -RFX";

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
