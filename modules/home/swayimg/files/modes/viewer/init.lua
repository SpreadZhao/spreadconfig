require("modes/viewer/text")
require("modes/viewer/bindings")

swayimg.viewer.default_scale = "fit"
swayimg.viewer.set_window_background(0xff111111)
swayimg.viewer.set_image_background(0xff111111)
swayimg.viewer.mark_color = 0xffffffff

if swayimg.appid == "swayimg-pin" then
  local window_ready = false

  local function fit_window_to_image()
    local image = swayimg.viewer.get_image()
    if image then
      swayimg.set_window_size(image.width, image.height)
      swayimg.viewer.set_fix_scale("fit")
    end
  end

  swayimg.viewer.on_image_change(function()
    if window_ready then
      fit_window_to_image()
    end
  end)

  swayimg.on_window_resize(function()
    if not window_ready then
      window_ready = true
      fit_window_to_image()
      return
    end
    if swayimg.mode == "viewer" then
      swayimg.viewer.set_fix_scale("fit")
    end
  end)
end
