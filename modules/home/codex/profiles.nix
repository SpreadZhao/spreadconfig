{
  lib,
  pkgs,
  codexPackage,
  names,
}:

let
  mkProfile =
    profile:
    let
      command = "codex-${profile}";
      launcher = pkgs.writeShellApplication {
        name = command;
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
          profile_home="$data_home/codex/profiles/${profile}"
          umask 077
          mkdir -p -- "$profile_home"
          export CODEX_HOME="$profile_home"
          export CODEX_CLI_PATH=${lib.escapeShellArg (lib.getExe codexPackage)}
          unset CODEX_SQLITE_HOME
          exec ${lib.getExe codexPackage} "$@"
        '';
      };
    in
    pkgs.runCommand "${command}-${codexPackage.version}"
      {
        nativeBuildInputs = [ pkgs.installShellFiles ];
        meta = {
          description = "Codex CLI with the ${profile} account profile";
          mainProgram = command;
        };
      }
      ''
        mkdir -p "$out/bin" "$TMPDIR/completion-home"
        ln -s ${lib.getExe launcher} "$out/bin/${command}"
        export CODEX_HOME="$TMPDIR/completion-home"
        for shell in bash fish zsh; do
          ${lib.getExe codexPackage} completion "$shell" \
            | sed 's/codex/${command}/g' > "$TMPDIR/completion.$shell"
        done
        installShellCompletion --cmd ${command} \
          --bash "$TMPDIR/completion.bash" \
          --fish "$TMPDIR/completion.fish" \
          --zsh "$TMPDIR/completion.zsh"
      '';
in
lib.genAttrs (map (name: "codex-${name}") names) (name: mkProfile (lib.removePrefix "codex-" name))
