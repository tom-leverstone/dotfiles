#!/bin/bash

set -e

# Skip machines without an EFS mount configured.
[[ -n "${EFS_MOUNT_POINT:-}" ]] || exit 0

umask 077
auth_root="$EFS_MOUNT_POINT/.cli-auth"
mkdir -p "$auth_root"
chmod 700 "$auth_root"

link_auth() {
    local source="$1" target="$auth_root/$2"
    # Already linked correctly: repeated setup needs no changes.
    if [[ -L "$source" && "$(readlink "$source")" == "$target" ]]; then
        return 0
    fi
    # Refuse to replace another symlink or overwrite either existing copy.
    if [[ -L "$source" || ( -e "$source" && -e "$target" ) ]]; then
        echo "Auth conflict: reconcile $source and $target manually." >&2
        return 1
    fi
    mkdir -p "$(dirname "$source")" "$(dirname "$target")"
    # Preserve existing local credentials by moving them to the shared drive.
    if [[ -e "$source" ]]; then
        mv "$source" "$target"
    fi
    ln -s "$target" "$source"
}

# Add one mapping per CLI; keep non-secret configuration local.
link_auth "${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/auth.json" "pi/auth.json"
link_auth "${XDG_CONFIG_HOME:-$HOME/.config}/acli/jira_config.yaml" "acli/jira_config.yaml"
link_auth "${XDG_CONFIG_HOME:-$HOME/.config}/slack-vanta/token.json" "slack-vanta/token.json"
