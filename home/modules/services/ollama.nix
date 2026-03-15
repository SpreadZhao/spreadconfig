{ pkgs-old-dd9b079, ... }:

{
    services.ollama = {
        enable = true;
        package = pkgs-old-dd9b079.ollama-rocm;
        acceleration = "rocm";
        host = "127.0.0.1";
        port = 11434;
    };
}
