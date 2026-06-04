{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "SpreadZhao";
        email = "spreadzhao@outlook.com";
      };
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
