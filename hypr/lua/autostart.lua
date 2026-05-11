return function(apps)
  hl.on("hyprland.start", function()
    for _, command in ipairs(apps.autostart) do
      hl.exec_cmd(command)
    end
  end)
end
