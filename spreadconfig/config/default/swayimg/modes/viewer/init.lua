require("modes/viewer/text")
require("modes/viewer/bindings")

swayimg.viewer.set_default_scale("fit")
swayimg.viewer.set_window_background(0xff111111)
swayimg.viewer.set_image_background(0xff111111)
swayimg.viewer.set_mark_color(0xffffffff)

if swayimg.get_appid() == "swayimg-pin" then
  swayimg.viewer.on_image_change(function()
    local image = swayimg.viewer.get_image()
    if image then
      swayimg.set_window_size(image.width, image.height)
      swayimg.viewer.set_fix_scale("fit")
    end
  end)
end
