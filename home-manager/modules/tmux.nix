{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    # Use fish as default shell
    shell = "${pkgs.fish}/bin/fish";

    # Basic settings
    terminal = "screen-256color";
    escapeTime = 0;
    historyLimit = 10000;
    mouse = true;
    baseIndex = 1;

    # Prefix key
    prefix = "C-a";

    # Plugins (replaces TPM!)
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      # Terminal overrides
      set -ga terminal-overrides ",*256col*:Tc"
      set -g focus-events on

      # Window settings
      set -g set-titles on
      set -g set-titles-string '#S ● #I #W'
      set -g renumber-windows on
      setw -g automatic-rename on
      setw -g automatic-rename-format '#{?#{||:#{==:#{pane_current_command},zsh},#{==:#{pane_current_command},fish}},#{pane_current_command},#{?#{m/r:^[0-9]+\.[0-9]+\.[0-9]+$,#{pane_current_command}},claude,#{pane_current_command}}}(#{b:pane_current_path})'
      setw -g monitor-activity on
      set -g visual-activity off
      setw -g aggressive-resize on

      # Pane settings
      setw -g pane-base-index 1

      # Key bindings
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick pane cycling
      bind -r Tab select-pane -t :.+

      # Session management
      bind S new-session
      bind N new-session -d
      bind X switch-client -l \; kill-session -t !

      # Window management
      bind c new-window -c "#{pane_current_path}"
      bind -r n next-window
      bind -r p previous-window

      # Copy mode
      setw -g mode-keys vi
      bind Enter copy-mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Sesh integration
      bind-key "o" display-popup -E -w 35% -h 60% \
        "sesh connect \$(sesh list --icons | fzf --no-sort --no-info --no-scrollbar --cycle --reverse --ansi --bind='tab:down,shift-tab:up,ctrl-j:accept' --prompt='⚡ ')"
      bind-key "O" run-shell "sesh connect \$(sesh list -t | head -1)"
      bind-key "C-o" run-shell "sesh connect \$(pwd)"

      # ── Everforest Dark Medium Theme ──
      # Color palette
      set -g @everforest_bg_dim '#232a2e'
      set -g @everforest_bg0 '#2d353b'
      set -g @everforest_bg1 '#343f44'
      set -g @everforest_bg2 '#3d484d'
      set -g @everforest_bg3 '#475258'
      set -g @everforest_bg4 '#4f585e'
      set -g @everforest_bg5 '#56635f'
      set -g @everforest_bg_visual '#543a48'
      set -g @everforest_bg_red '#514045'
      set -g @everforest_bg_green '#425047'
      set -g @everforest_bg_blue '#3a515d'
      set -g @everforest_bg_yellow '#4d4c43'
      set -g @everforest_fg '#d3c6aa'
      set -g @everforest_red '#e67e80'
      set -g @everforest_orange '#e69875'
      set -g @everforest_yellow '#dbbc7f'
      set -g @everforest_green '#a7c080'
      set -g @everforest_aqua '#83c092'
      set -g @everforest_blue '#7fbbb3'
      set -g @everforest_purple '#d699b6'
      set -g @everforest_grey0 '#7a8478'
      set -g @everforest_grey1 '#859289'
      set -g @everforest_grey2 '#9da9a0'
      set -g @everforest_statusline1 '#a7c080'
      set -g @everforest_statusline2 '#d3c6aa'
      set -g @everforest_statusline3 '#e67e80'

      # Status bar
      set -g status on
      set -g status-interval 2
      set -g status-position top
      set -g status-fg '#d3c6aa'
      set -g status-bg '#2d353b'
      set -g status-style fg='#{@everforest_fg}',bg='#{@everforest_bg_dim}',default

      # Mode style (copy mode, etc.)
      set -g mode-style fg='#{@everforest_purple}',bg='#{@everforest_bg_red}'

      # Window styles
      setw -g window-status-style fg='#{@everforest_bg5}',bg='#{@everforest_bg0}'
      setw -g window-status-activity-style bg='#{@everforest_bg1}',fg='#{@everforest_bg3}'
      setw -g window-status-current-style fg='#{@everforest_fg}',bg='#{@everforest_bg_green}'
      setw -g window-status-bell-style fg='#{@everforest_bg0}',bg='#{@everforest_statusline3}'

      # Pane borders
      set -g pane-border-style fg='#{@everforest_bg1}'
      set -g pane-active-border-style fg='#{@everforest_blue}'
      set -g display-panes-active-colour '#7fbbb3'
      set -g display-panes-colour '#e69875'

      # Messages
      set -g message-style fg='#{@everforest_statusline3}',bg='#{@everforest_bg_dim}'
      set -g message-command-style fg='#{@everforest_bg3}',bg='#{@everforest_bg1}'

      # Clock
      setw -g clock-mode-colour '#7fbbb3'

      # Status bar formatting
      set -g status-left-style none
      set -g status-left-length 60
      set -g status-left '#[fg=#{@everforest_bg_dim},bg=#{@everforest_green},bold] #S #[fg=#{@everforest_green},bg=#{@everforest_bg2},nobold]#[fg=#{@everforest_green},bg=#{@everforest_bg2},bold] #(whoami) #[fg=#{@everforest_bg2},bg=#{@everforest_bg0},nobold]'

      set -g status-right-style none
      set -g status-right-length 150
      set -g status-right '#[fg=#{@everforest_bg2}]#[fg=#{@everforest_fg},bg=#{@everforest_bg2}] #[fg=#{@everforest_fg},bg=#{@everforest_bg2}]%Y-%m-%d  %H:%M #[fg=#{@everforest_aqua},bg=#{@everforest_bg2},bold]#[fg=#{@everforest_bg_dim},bg=#{@everforest_aqua},bold] #h '

      set -g window-status-separator '#[fg=#{@everforest_grey2},bg=#{@everforest_bg0}] '
      set -g window-status-format '#[fg=#{@everforest_grey0},bg=#{@everforest_bg0}] #I  #[fg=#{@everforest_grey0},bg=#{@everforest_bg0}]#W '
      set -g window-status-current-format '#[fg=#{@everforest_bg0},bg=#{@everforest_bg_green}]#[fg=#{@everforest_fg},bg=#{@everforest_bg_green}] #I  #[fg=#{@everforest_fg},bg=#{@everforest_bg_green},bold]#W #[fg=#{@everforest_bg_green},bg=#{@everforest_bg0},nobold]'
    '';
  };

  # Additional packages
  home.packages = [ pkgs.sesh ];
}
