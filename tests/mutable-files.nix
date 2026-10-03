{ lib, repoRoot }:

let
  helpers = import ../lib/mutable-files.nix {
    inherit lib repoRoot;
    projDir = "/tmp/checkout with spaces";
    mkOutOfStoreSymlink = path: path;
    pkgs.linkFarm = name: entries: { inherit name entries; };
  };
  accepted = value: (builtins.tryEval (builtins.deepSeq value true)).success;
in
lib.runTests {
  testRuntimePathIsNotStoreSource = {
    expr = helpers.repoLink "README.md";
    expected = "/tmp/checkout with spaces/README.md";
  };
  testMissingFileFails = {
    expr = accepted (helpers.repoLink "does-not-exist");
    expected = false;
  };
  testDirectoryIsNotAFile = {
    expr = accepted (helpers.repoLink "hosts");
    expected = false;
  };
  testRejectInvalidSources = {
    expr = lib.any (path: accepted (helpers.repoLink path)) [
      "../README.md"
      "/README.md"
      "hosts/../README.md"
      "./README.md"
      ""
    ];
    expected = false;
  };
  testRejectInvalidTargets = {
    expr = accepted (helpers.repoTree "test" { "../outside" = "/some/source"; });
    expected = false;
  };
  testRejectFileDirectoryCollision = {
    expr = accepted (
      helpers.repoTree "test" {
        foo = "/some/source";
        "foo/bar" = "/another/source";
      }
    );
    expected = false;
  };
  testEnumerateFiles = {
    expr = helpers.repoEntries "tests/fixtures/mutable-files";
    expected = {
      "top.txt" = "/tmp/checkout with spaces/tests/fixtures/mutable-files/top.txt";
      "nested/with space.txt" =
        "/tmp/checkout with spaces/tests/fixtures/mutable-files/nested/with space.txt";
    };
  };
} == [ ]
