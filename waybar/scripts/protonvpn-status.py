#!/usr/bin/env python3
"""Report the Proton app's NetworkManager tunnel state to Waybar."""

import json
import os
from pathlib import Path
import re
import subprocess


def server_country(server):
    # Secure Core names include entry and exit countries (e.g. CH-US#1).
    match = re.fullmatch(r"(?:[A-Z]{2}-)?([A-Z]{2})(?:#\d+|-.*)", server)
    if not match:
        return None
    code = match[1]
    try:
        countries = json.loads(
            Path("/usr/share/iso-codes/json/iso_3166-1.json").read_text()
        )["3166-1"]
        return next(
            country.get("common_name", country["name"])
            for country in countries
            if country["alpha_2"] == code
        )
    except (OSError, ValueError, KeyError, TypeError, StopIteration):
        return code


def status():
    try:
        result = subprocess.run(
            [
                "nmcli",
                "-t",
                "-f",
                "DEVICE,STATE,NAME",
                "connection",
                "show",
                "--active",
            ],
            capture_output=True,
            text=True,
            check=True,
            timeout=3,
            env={**os.environ, "LC_ALL": "C"},
        )
    except (OSError, subprocess.SubprocessError):
        return {
            "text": "󰦞 VPN ?",
            "class": "unknown",
            "tooltip": "Proton VPN status unavailable: could not query NetworkManager",
        }

    # The installed Proton WireGuard, OpenVPN and Stealth backends use proton0.
    # Kill-switch and IPv6 leak-protection connections are not VPN tunnels.
    for line in result.stdout.splitlines():
        if not line.startswith("proton0:activated:"):
            continue
        name = line.split(":", 2)[2]
        server = name.removeprefix("ProtonVPN ")
        country = server_country(server)
        return {
            "text": "󰒃 VPN ON" + (f" · {country}" if country else ""),
            "class": "connected",
            "tooltip": "Proton VPN tunnel connected (proton0)"
            + (f"\nCountry: {country}" if country else "")
            + f"\nServer: {server}",
        }
    return {
        "text": "󰦞 VPN OFF",
        "class": "disconnected",
        "tooltip": "Proton VPN tunnel disconnected",
    }


if __name__ == "__main__":
    print(json.dumps(status()))
