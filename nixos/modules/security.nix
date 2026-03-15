{ ... }:

{
    security = {
        polkit = {
            enable = true;
            # https://wiki.nixos.org/wiki/Polkit#No_password_for_wheel
            extraConfig = ''
                polkit.addRule(function(action, subject) {
                    if (subject.isInGroup("wheel"))
                        return polkit.Result.YES;
                });
            '';
        };
        pam.services = {
            # https://wiki.nixos.org/wiki/Secret_Service#Auto-decrypt_on_login
            # login.enableGnomeKeyring = true;
            # https://github.com/swaywm/sway/issues/2773#issuecomment-427570877
            # https://wiki.nixos.org/wiki/Swaylock#Home_Manager_-_Through_Sway
            swaylock = { };
        };
        sudo.wheelNeedsPassword = false;
    };
}
