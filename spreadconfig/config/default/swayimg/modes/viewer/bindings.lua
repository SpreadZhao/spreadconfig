local chessboard = false
local touchpad_pan_step = 60

local function toggle_animation()
  swayimg.viewer.animation = not swayimg.viewer.animation
end

local function toggle_antialiasing()
  swayimg.antialiasing = not swayimg.antialiasing
end

local function toggle_chessboard()
  chessboard = not chessboard
  if chessboard then
    swayimg.viewer.set_image_chessboard(8, 0xff666666, 0xff999999)
  else
    swayimg.viewer.set_image_background(0xff111111)
  end
end

local function toggle_text()
  swayimg.text.visible = not swayimg.text.visible
end

local function move_horizontal(direction)
  local window = swayimg.get_window_size()
  local position = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(
    math.floor(position.x + direction * window.width / 10),
    position.y
  )
end

local function move_vertical(direction)
  local window = swayimg.get_window_size()
  local position = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(
    position.x,
    math.floor(position.y + direction * window.height / 10)
  )
end

local function scale_by(factor)
  swayimg.viewer.set_abs_scale(swayimg.viewer.scale * factor)
end

local function pan_horizontal(distance)
  local position = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(position.x + distance, position.y)
end

local function pan_vertical(distance)
  local position = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(position.x, position.y + distance)
end

swayimg.viewer.on_key("q", function()
  swayimg.exit(0)
end)
swayimg.viewer.on_key("Escape", function()
  swayimg.exit(0)
end)
swayimg.viewer.on_key("Ctrl+n", function()
  swayimg.viewer.open("next_dir")
end)
swayimg.viewer.on_key("Ctrl+p", function()
  swayimg.viewer.open("prev_dir")
end)
swayimg.viewer.on_key("Return", function()
  swayimg.mode = "gallery"
end)
swayimg.viewer.on_key("s", function()
  swayimg.mode = "slideshow"
end)
swayimg.viewer.on_key("m", toggle_text)
swayimg.viewer.on_key("f", function()
  swayimg.fullscreen = not swayimg.fullscreen
end)
swayimg.viewer.on_key("g", function()
  swayimg.viewer.open("first")
end)
swayimg.viewer.on_key("Shift+g", function()
  swayimg.viewer.open("last")
end)
swayimg.viewer.on_key("h", function()
  move_horizontal(1)
end)
swayimg.viewer.on_key("Left", function()
  move_horizontal(1)
end)
swayimg.viewer.on_key("j", function()
  move_vertical(-1)
end)
swayimg.viewer.on_key("Down", function()
  move_vertical(-1)
end)
swayimg.viewer.on_key("k", function()
  move_vertical(1)
end)
swayimg.viewer.on_key("Up", function()
  move_vertical(1)
end)
swayimg.viewer.on_key("l", function()
  move_horizontal(-1)
end)
swayimg.viewer.on_key("Right", function()
  move_horizontal(-1)
end)
swayimg.viewer.on_key("i", function()
  scale_by(1.1)
end)
swayimg.viewer.on_key("o", function()
  scale_by(0.9)
end)
swayimg.viewer.on_key("n", function()
  swayimg.viewer.open("next")
end)
swayimg.viewer.on_key("p", function()
  swayimg.viewer.open("prev")
end)
swayimg.viewer.on_key("z", function()
  swayimg.viewer.reset()
end)
swayimg.viewer.on_key("comma", function()
  local frame = swayimg.viewer.frame
  if frame > 0 then
    swayimg.viewer.frame = frame - 1
  end
end)
swayimg.viewer.on_key("period", function()
  swayimg.viewer.frame = swayimg.viewer.frame + 1
end)
swayimg.viewer.on_key("space", toggle_animation)
swayimg.viewer.on_key("Ctrl+r", function()
  swayimg.viewer.rotate(270)
end)
swayimg.viewer.on_key("r", function()
  swayimg.viewer.rotate(90)
end)
swayimg.viewer.on_key("Ctrl+v", function()
  swayimg.viewer.flip_horizontal()
end)
swayimg.viewer.on_key("v", function()
  swayimg.viewer.flip_vertical()
end)
swayimg.viewer.on_key("a", toggle_antialiasing)
swayimg.viewer.on_key("Shift+a", toggle_chessboard)
swayimg.viewer.on_key("w", function()
  swayimg.viewer.set_fix_scale("width")
end)
swayimg.viewer.on_key("e", function()
  swayimg.viewer.set_fix_scale("height")
end)
swayimg.viewer.on_key("/", function()
  swayimg.viewer.set_fix_scale("fit")
end)
swayimg.viewer.on_key("Shift+f", function()
  swayimg.viewer.set_fix_scale("fill")
end)
swayimg.viewer.on_key("t", swayimg.viewer.mark_image)

swayimg.viewer.on_mouse("ScrollUp", function()
  pan_vertical(touchpad_pan_step)
end)
swayimg.viewer.on_mouse("ScrollDown", function()
  pan_vertical(-touchpad_pan_step)
end)
swayimg.viewer.on_mouse("ScrollLeft", function()
  pan_horizontal(touchpad_pan_step)
end)
swayimg.viewer.on_mouse("ScrollRight", function()
  pan_horizontal(-touchpad_pan_step)
end)
