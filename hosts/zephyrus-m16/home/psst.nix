{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  basePackage = inputs.personal-packages.packages.${pkgs.stdenv.hostPlatform.system}.psst-auth;
  psst = pkgs.symlinkJoin {
    name = "psst-auth-configured-${basePackage.version}";
    paths = [ basePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # Intel Iris Xe: avoid GPUI/Blade repaint freezes on the NVIDIA GPU.
    # Both Pinentry and the Polkit agent (including its child) use this wrapper.
    postBuild = ''
      for program in psst-pinentry psst-polkit-agent; do
        wrapProgram "$out/bin/$program" \
          --set ZED_DEVICE_ID ${lib.escapeShellArg "46a6"}
      done
    '';
  };
in
{
  services.gpg-agent.pinentry.package = psst;
}
