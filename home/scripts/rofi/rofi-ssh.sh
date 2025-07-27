#!/usr/bin/env bash

set -euo pipefail

ssh_menu() {
    ROFI_THEME="$HOME/.config/rofi/themes/chiaroscuro.rasi"

    # Define SSH connections
    local options=(
        "⊹ Connect to Axlecoffee <i>(Main Server)</i>"
        "⊹ Connect to Axlecoffee (Root) <i>(Admin Access)</i>"
        "⊹ SFTP to Axlecoffee <i>(File Transfer)</i>"
        "⊹ SSH Tunnel to Axlecoffee <i>(Port Forward)</i>"
        "⊹ Mount Axlecoffee via SSHFS <i>(Remote Filesystem)</i>"
        "⊹ Check Axlecoffee Status <i>(Ping Test)</i>"
    )

    selected=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -P "λ " -theme "$ROFI_THEME" -markup-rows)
    [[ -z "$selected" ]] && return

    # Terminal for SSH sessions
    TERM_CMD="kitty -e"

    case "$selected" in
    *"Connect to Axlecoffee (Root)"*)
        $TERM_CMD ssh root@axlecoffee
        ;;
    *"Connect to Axlecoffee"*)
        $TERM_CMD ssh axlecoffee
        ;;
    *"SFTP to Axlecoffee"*)
        $TERM_CMD sftp axlecoffee
        ;;
    *"SSH Tunnel to Axlecoffee"*)
        # Get port for tunnel
        port=$(rofi -dmenu -P "Local port: " -theme "$ROFI_THEME")
        [[ -z "$port" ]] && return
        remote_port=$(rofi -dmenu -P "Remote port: " -theme "$ROFI_THEME")
        [[ -z "$remote_port" ]] && return

        $TERM_CMD ssh -L "$port:localhost:$remote_port" axlecoffee
        notify-send "SSH" "Tunnel created: localhost:$port -> axlecoffee:$remote_port"
        ;;
    *"Mount Axlecoffee via SSHFS"*)
        # Create mount point if it doesn't exist
        mount_point="$HOME/mnt/axlecoffee"
        mkdir -p "$mount_point"

        # Check if already mounted
        if mountpoint -q "$mount_point"; then
            # Unmount
            fusermount -u "$mount_point"
            notify-send "SSHFS" "Unmounted Axlecoffee from $mount_point"
        else
            # Mount
            sshfs axlecoffee: "$mount_point"
            notify-send "SSHFS" "Mounted Axlecoffee to $mount_point"
        fi
        ;;
    *"Check Axlecoffee Status"*)
        $TERM_CMD bash -c "ping -c 4 axlecoffee && echo 'Press Enter to close...' && read"
        ;;
    esac
}

ssh_menu
