swayimg.set_mode("viewer")
swayimg.imagelist.set_order("none")

swayimg.on_window_resize(function()
  if swayimg.get_mode() == "viewer" then
    swayimg.viewer.set_fix_scale("fit")
  end
end)
