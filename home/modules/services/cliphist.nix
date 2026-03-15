{ ... }:

{
    services.cliphist = {
        enable = true;
        extraOptions = [
            "-max-items"
            "1000"
        ];
    };
}
