{ pkgs }:

{
  docsify-cli = pkgs.callPackage ./docsify-cli { };
  github-copilot-app = pkgs.callPackage ./github-copilot-app { };
}
