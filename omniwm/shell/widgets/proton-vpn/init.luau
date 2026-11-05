local function openProton()
    omniwm.open("protonvpn://", function(result)
        if not result.ok then
            omniwm.log("Cannot open Proton VPN:", result.error)
        end
    end)
end

function render(ctx)
    local hidden = ctx.data.hiddenBar
    if hidden and hidden.enabled and hidden.available then
        for _, item in ipairs(hidden.items) do
            local name = string.lower(item.name):gsub("[%s%-_]", "")
            if name == "protonvpn" then
                local icon = ui.symbol{ name = "network", w = 16, h = 16 }
                if item.image then
                    icon = ui.image{ image = item.image, w = item.w, h = item.h }
                end

                return ui.stack{ key = item.id, w = math.ceil(item.w) + 8, h = 22,
                    help = "Proton VPN", onClick = "hidden-bar activate " .. item.id,
                    icon }
            end
        end
    end

    -- The launcher does not indicate VPN connection status.
    return ui.row{ key = "proton-vpn", gap = 4, pad = 4, h = 22, radius = 4,
        hover = "foreground/0.12", help = "Open Proton VPN (status unavailable)",
        onClick = openProton,
        ui.symbol{ name = "network", w = 16, h = 16 },
        ui.text{ text = "VPN", size = 12 } }
end
