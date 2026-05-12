return function()
  hl.monitor({
    output = "DP-1",
    mode = "preferred",
    position = "1298x670@",
    scale = "1.5",
  })

  hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "0x0",
    scale = "1.67",
    transform = 1,
  })
end
