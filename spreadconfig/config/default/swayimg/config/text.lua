swayimg.text.set_timeout(0)
if swayimg.get_appid() == "swayimg-pin" then
  swayimg.text.hide()
else
  swayimg.text.show()
end
swayimg.text.set_font("SourceCodePro")
swayimg.text.set_size(20)
swayimg.text.set_padding(2)
swayimg.text.set_foreground(0xffdddddd)
swayimg.text.set_shadow(0xff222222)
