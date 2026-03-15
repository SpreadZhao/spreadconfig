{ defaultJDK, ... }:

{
    programs.java = {
        enable = true;
        package = defaultJDK;
    };
}
