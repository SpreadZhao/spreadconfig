{ pkgs, ... }:

{
    services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        acceleration = "rocm";
        host = "127.0.0.1";
        port = 11434;
    };
}
