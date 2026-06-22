{ ... }:

{
  programs.ydotool = {
    enable = true;
    group = "ydotool";
  };

  users.users.spreadzhao.extraGroups = [ "ydotool" ];
}
