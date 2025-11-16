# Only run the rest in interactive sessions
status is-interactive; or return

# ---- PATHS ----
# Use $HOME instead of a hard-coded username
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

# ---- ENV VARS (NON-SECRET) ----
# Safe to keep public
set -gx CARGO_NET_GIT_FETCH_WITH_CLI true
set -gx EDITOR nvim

# ---- TIDE / JJ PROMPT SETTINGS ----
# JJ-specific prompt customisation
set -U tide_left_prompt_items os pwd jj newline character
set -U tide_jj_icon ''
set -g tide_jj_bg_color yellow
set -g tide_jj_color black
set -g tide_jj_op_log_id_bg_color yellow
set -g tide_jj_op_log_id_color yellow

# ---- LOCAL OVERRIDES (NOT COMMITTED) ----
# Put secrets + machine-specific tweaks in config.local.fish
if test -f $HOME/.config/fish/config.local.fish
    source $HOME/.config/fish/config.local.fish
end

function update_submodule
    git submodule update --init --recursive
    git submodule update --remote
end

function kill_windows
    pkill windows
end

function fish_greeting
    if set -q fish_greeting
        test -n "$fish_greeting"
        and echo $fish_greeting
        return
    end
end
