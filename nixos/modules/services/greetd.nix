{ pkgs, ... }:

{
    services.greetd = {
        enable = true;
        settings = {
            terminal = {
                vt = 1;
            };
            default_session = {
                command = "${pkgs.greetd}/bin/agreety --cmd zsh";
                user = "greeter";
            };
            initial_session = {
                command = "niri-session";
                user = "spreadzhao";
            };
        };
    };
}
