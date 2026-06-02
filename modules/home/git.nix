{
  programs.git = {
    enable = true;
    userName = "SpreadZhao";
    userEmail = "spreadzhao@outlook.com";
    settings = {
      credential = {
        "https://github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
        "https://gist.github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
      };
    };
  };
}
