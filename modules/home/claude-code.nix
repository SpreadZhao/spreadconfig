{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];

  # Claude Code writes model selection and other runtime settings to
  # settings.json, so activation seeds the file only when it is missing or a
  # symlink, and never overwrites an existing regular file. Delete the file and
  # activate again to re-seed it.
  home.activation.seedClaudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    src=${lib.escapeShellArg osConfig.sops.templates."claude-settings.json".path}
    dest="$HOME/.claude/settings.json"
    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
      :
    elif [ -r "$src" ]; then
      run ${pkgs.coreutils}/bin/mkdir -p -- "$HOME/.claude"
      run ${pkgs.coreutils}/bin/rm -f -- "$dest"
      run ${pkgs.coreutils}/bin/install -m 600 -- "$src" "$dest"
    fi
  '';
}
