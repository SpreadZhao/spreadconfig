{ appEntries, ... }:
{
  services.cliphist = {
    enable = true;
    allowImages = true;
    extraOptions = [
      "-max-items"
      "1000"
    ];
  };
  spreadconfig.scriptFiles = appEntries "clipboard-history" "scripts";
}
