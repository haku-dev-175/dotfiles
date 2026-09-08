# Tide prompt — fish-native replacement for starship.
#
# Tide normally stores its configuration in universal variables written by the
# interactive `tide configure` wizard, which is not reproducible. Instead the
# settings live here and are emitted as `set -g` lines: global scope shadows
# universal scope, so this file wins over anything a stray wizard run left in
# fish_variables.
{ config, pkgs, lib, ... }:

let
  # Tide's own palette, from functions/_tide_sub_configure.fish.
  darkBlue = "0087AF";
  darkGreen = "5FAF00";
  gold = "D7AF00";
  green = "5FD700";
  lightBlue = "00AFFF";

  settings = {
    # ---- Prompt shape ----------------------------------------------------
    # Two lines: pwd + git on top, prompt character below. `newline` is what
    # splits them, and it must stay in the left items for the two-line
    # rendering path in fish_prompt.fish to be taken.
    prompt_add_newline_before = "true";
    prompt_color_frame_and_connection = "6C6C6C";
    prompt_color_separator_same_color = "949494";
    prompt_min_cols = "34";
    prompt_pad_items = "false";
    prompt_transient_enabled = "false";

    left_prompt_frame_enabled = "false";
    left_prompt_items = [ "pwd" "git" "newline" "character" ];
    left_prompt_prefix = "";
    left_prompt_separator_diff_color = " ";
    left_prompt_separator_same_color = " ";
    left_prompt_suffix = " ";

    # Ordered to match the old starship.toml: status, duration, host/user,
    # then language versions, then infra context, then the clock.
    right_prompt_frame_enabled = "false";
    right_prompt_items = [
      "status" "cmd_duration" "context" "jobs"
      "node" "python" "rustc" "go" "java" "ruby"
      "docker" "kubectl" "aws" "terraform" "nix_shell" "direnv"
      "time"
    ];
    right_prompt_prefix = " ";
    right_prompt_separator_diff_color = " ";
    right_prompt_separator_same_color = " ";
    right_prompt_suffix = "";

    # ---- Character -------------------------------------------------------
    character_color = green;
    character_color_failure = "FF0000";

    # ---- pwd -------------------------------------------------------------
    pwd_bg_color = "normal";
    pwd_color_anchors = lightBlue;
    pwd_color_dirs = darkBlue;
    pwd_color_truncated_dirs = "8787AF";
    pwd_markers = [
      ".git" ".hg" ".svn" ".bzr"
      ".node-version" ".python-version" ".ruby-version" ".terraform"
      "Cargo.toml" "composer.json" "go.mod" "package.json"
    ];

    # ---- git -------------------------------------------------------------
    git_bg_color = "normal";
    git_bg_color_unstable = "normal";
    git_bg_color_urgent = "normal";
    git_color_branch = green;
    git_color_conflicted = "FF0000";
    git_color_dirty = gold;
    git_color_operation = "FF0000";
    git_color_staged = gold;
    git_color_stash = green;
    git_color_untracked = lightBlue;
    git_color_upstream = green;
    git_truncation_length = "24";
    git_truncation_strategy = "";

    # ---- status / duration / jobs ---------------------------------------
    status_bg_color = "normal";
    status_bg_color_failure = "normal";
    status_color = darkGreen;
    status_color_failure = "D70000";

    # starship used cmd_duration.min_time = 2000.
    cmd_duration_bg_color = "normal";
    cmd_duration_color = "87875F";
    cmd_duration_decimals = "0";
    cmd_duration_threshold = "2000";

    jobs_bg_color = "normal";
    jobs_color = darkGreen;
    jobs_number_threshold = "1000";

    # ---- context (user@host) --------------------------------------------
    # starship showed username only when notable and hostname only over SSH;
    # that is exactly tide's default context behaviour.
    context_always_display = "false";
    context_bg_color = "normal";
    context_color_default = "D7AF87";
    context_color_root = gold;
    context_color_ssh = "D7AF87";
    context_hostname_parts = "1";

    # ---- languages -------------------------------------------------------
    node_bg_color = "normal";
    node_color = "44883E";
    python_bg_color = "normal";
    python_color = "00AFAF";
    rustc_bg_color = "normal";
    rustc_color = "F74C00";
    go_bg_color = "normal";
    go_color = "00ACD7";
    java_bg_color = "normal";
    java_color = "ED8B00";
    ruby_bg_color = "normal";
    ruby_color = "B31209";

    # ---- infra -----------------------------------------------------------
    docker_bg_color = "normal";
    docker_color = "2496ED";
    docker_default_contexts = [ "default" "colima" ];
    kubectl_bg_color = "normal";
    kubectl_color = "326CE5";
    aws_bg_color = "normal";
    aws_color = "FF9900";
    terraform_bg_color = "normal";
    terraform_color = "844FBA";
    nix_shell_bg_color = "normal";
    nix_shell_color = "7EBAE4";
    direnv_bg_color = "normal";
    direnv_bg_color_denied = "normal";
    direnv_color = gold;
    direnv_color_denied = "FF0000";

    # ---- clock -----------------------------------------------------------
    # starship used %R (hour:minute); tide's default is %T (with seconds).
    time_bg_color = "normal";
    time_color = "5F8787";
    time_format = "%R";

    # ---- vi mode ---------------------------------------------------------
    vi_mode_bg_color_default = "normal";
    vi_mode_bg_color_insert = "normal";
    vi_mode_bg_color_replace = "normal";
    vi_mode_bg_color_visual = "normal";
    vi_mode_color_default = "949494";
    vi_mode_color_insert = "87AFAF";
    vi_mode_color_replace = "87AF87";
    vi_mode_color_visual = "FF8700";

    # ---- Icons ----------------------------------------------------------
    # Tide's icons are normally written by the `tide configure` wizard's
    # "many icons" choice; these are those values. They need a Nerd Font,
    # which the old starship.toml already assumed.
    character_icon = "➜";
    # This machine uses fish's default (emacs) key bindings, but fish leaves
    # $fish_key_bindings empty and reports $fish_bind_mode as "default", so
    # _tide_item_character takes its vi branch and would draw the vi icon.
    # Matching it to character_icon keeps the arrow starship used.
    character_vi_icon_default = "➜";
    character_vi_icon_replace = "▶";
    character_vi_icon_visual = "V";
    prompt_icon_connection = " ";
    pwd_icon = "";
    pwd_icon_home = "";
    pwd_icon_unwritable = "";
    git_icon = "";
    cmd_duration_icon = "";
    status_icon = "✔";
    status_icon_failure = "✘";
    jobs_icon = "";
    shlvl_icon = "";
    node_icon = "";
    python_icon = "󰌠";
    rustc_icon = "";
    go_icon = "";
    java_icon = "";
    ruby_icon = "";
    docker_icon = "";
    kubectl_icon = "󱃾";
    aws_icon = "";
    terraform_icon = "󱁢";
    nix_shell_icon = "";
    direnv_icon = "▼";
    vi_mode_icon_default = "D";
    vi_mode_icon_insert = "I";
    vi_mode_icon_replace = "R";
    vi_mode_icon_visual = "V";

    # ---- misc items ------------------------------------------------------
    shlvl_bg_color = "normal";
    shlvl_color = "d78700";
    shlvl_threshold = "1";
    private_mode_bg_color = "normal";
    private_mode_color = "FFFFFF";
    os_bg_color = "normal";
    os_color = "normal";
  };

  # Several tide variables (the prompt item lists, pwd markers, docker
  # contexts) are fish lists, not strings: each element must be a separate
  # argument or tide ends up looking for a command named after the whole
  # joined string.
  toSet =
    name: value:
    let
      parts = if builtins.isList value then value else [ value ];
    in
    "set -g tide_${name} ${lib.concatMapStringsSep " " lib.escapeShellArg parts}";
in
{
  programs.fish = {
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    # shellInit, not interactiveShellInit: tide renders the prompt in a
    # background non-interactive `fish -c`, and home-manager guards
    # interactiveShellInit behind `status is-interactive`, so the variables
    # would be missing exactly where the prompt is actually built. Tide's own
    # installer avoids this by using universal variables, which we don't want.
    shellInit = lib.mkBefore ''
      # Tide prompt configuration (see home-manager/modules/tide.nix)
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList toSet settings)}

      # Tide sets this on install to stop Python's own venv prompt from
      # duplicating the python segment.
      set -gx VIRTUAL_ENV_DISABLE_PROMPT true
    '';
  };
}
