#!/usr/bin/env bash
# Node.js development session: editor, a 4-pane services window, and git.
#
# Usage: dev-node.sh [session-name] [project-path]
#   session-name  defaults to "node-dev"
#   project-path  defaults to $PWD
set -euo pipefail

SESSION_NAME="${1:-node-dev}"
PROJECT_PATH="${2:-$PWD}"

# Attach from outside tmux, switch from inside it. `attach-session` refuses to
# nest, so a plain attach fails when this is run from a tmux key binding.
enter_session() {
    if [ -n "${TMUX:-}" ]; then
        tmux switch-client -t "$SESSION_NAME"
    else
        tmux attach-session -t "$SESSION_NAME"
    fi
}

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Switching..."
    enter_session
    exit 0
fi

# Main editor window
tmux new-session -d -s "$SESSION_NAME" -n editor -c "$PROJECT_PATH"
tmux send-keys -t "$SESSION_NAME:editor" 'nvim .' C-m

# Services window — 4 panes
tmux new-window -t "$SESSION_NAME" -n services -c "$PROJECT_PATH"
tmux split-window -t "$SESSION_NAME:services" -h -p 50 -c "$PROJECT_PATH"
tmux split-window -t "$SESSION_NAME:services.0" -v -p 50 -c "$PROJECT_PATH"
tmux split-window -t "$SESSION_NAME:services.2" -v -p 50 -c "$PROJECT_PATH"

tmux send-keys -t "$SESSION_NAME:services.0" 'npm run dev' C-m
tmux send-keys -t "$SESSION_NAME:services.1" 'npm run test:watch' C-m
tmux send-keys -t "$SESSION_NAME:services.2" 'docker compose logs -f' C-m
tmux send-keys -t "$SESSION_NAME:services.3" 'htop' C-m

# Git/terminal window
tmux new-window -t "$SESSION_NAME" -n git -c "$PROJECT_PATH"
tmux send-keys -t "$SESSION_NAME:git" 'git status' C-m

tmux select-window -t "$SESSION_NAME:editor"
enter_session
