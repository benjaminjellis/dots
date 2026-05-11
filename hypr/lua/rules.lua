return function()
  hl.window_rule({
    name = "opaque-mpv",
    match = { class = "^mpv$" },
    opacity = "1.0 override 1.0 override 1.0 override",
  })

  hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
  })

  hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
      class = "^$",
      title = "^$",
      xwayland = true,
      float = true,
      fullscreen = false,
      pin = false,
    },
    no_focus = true,
  })
end
