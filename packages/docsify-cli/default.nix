{
  lib,
  buildNpmPackage,
  importNpmLock,
  makeWrapper,
}:

buildNpmPackage {
  pname = "docsify-cli";
  version = "4.4.4";

  src = ./.;

  npmDeps = importNpmLock {
    npmRoot = ./.;
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ makeWrapper ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper $out/lib/node_modules/spreadconfig-docsify-cli/node_modules/docsify-cli/bin/docsify $out/bin/docsify \
      --set NO_UPDATE_NOTIFIER 1
  '';

  meta = {
    description = "A magical documentation generator.";
    homepage = "https://github.com/docsifyjs/docsify-cli";
    license = lib.licenses.mit;
    mainProgram = "docsify";
  };
}
