#!/usr/bin/env python3
"""Report the Proton app's NetworkManager tunnel state to Waybar."""

import json
import os
import subprocess


def status():
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "DEVICE,STATE", "connection", "show", "--active"],
            capture_output=True,
            text=True,
            check=True,
            timeout=3,
            env={**os.environ, "LC_ALL": "C"},
        )
    except (OSError, subprocess.SubprocessError):
        return {"text": "󰦞 VPN ?", "class": "unknown",
                "tooltip": "Proton VPN status unavailable: could not query NetworkManager"}

    # The installed Proton WireGuard, OpenVPN and Stealth backends use proton0.
    # Kill-switch and IPv6 leak-protection connections are not VPN tunnels.
    if "proton0:activated" in result.stdout.splitlines():
        return {"text": "󰒃 VPN ON", "class": "connected",
                "tooltip": "Proton VPN tunnel connected (proton0)"}
    return {"text": "󰦞 VPN OFF", "class": "disconnected",
            "tooltip": "Proton VPN tunnel disconnected"}


if __name__ == "__main__":
    print(json.dumps(status()))
