swayimg.mode = "viewer"
swayimg.imagelist.order = "none"

swayimg.on_window_resize(function()
  if swayimg.mode == "viewer" then
    swayimg.viewer.set_fix_scale("fit")
  end
end)
