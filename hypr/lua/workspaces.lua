return function()
  for workspace = 1, 10 do
    hl.workspace_rule({
      workspace = tostring(workspace),
      monitor = workspace % 2 == 1 and "DP-1" or "HDMI-A-1",
    })
  end
end
