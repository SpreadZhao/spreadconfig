{ ... }:

{
    programs.git = {
        enable = true;
        settings = {
            user = {
                name = "SpreadZhao";
                email = "spreadzhao@outlook.com";
            };
            core = {
                editor = "nvim";
            };
        };
    };
}
