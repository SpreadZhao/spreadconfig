{ lib, ... }:

let
  # Set address to enable an account; an empty realName uses the email address.
  # The first configured account is the default sender.
  # Thunderbird stores passwords, 163 app passwords and OAuth credentials.
  mailAccounts = [
    {
      name = "Outlook SpreadZhao";
      address = "spreadzhao@outlook.com";
      realName = "Spread Zhao";
      # Enable IMAP in the Outlook.com or Hotmail web settings.
      imap = {
        host = "outlook.office365.com";
        port = 993;
        authentication = "xoauth2";
        tls.enable = true;
      };
      smtp = {
        host = "smtp-mail.outlook.com";
        port = 587;
        authentication = "xoauth2";
        tls = {
          enable = true;
          useStartTls = true;
        };
      };
    }
    {
      name = "Gmail SpreadZhao";
      address = "spreadzhao@gmail.com";
      realName = "Spread Zhao";
      # The Gmail preset configures IMAP, SMTP, TLS and OAuth2.
      flavor = "gmail.com";
    }
    {
      name = "Gmail SuperZodiac";
      address = "supazodiac@gmail.com";
      realName = "Supa Zodiac";
      flavor = "gmail.com";
    }
    {
      name = "163 SpreadZhao";
      address = "bvm17486607@163.com";
      realName = "Spread Zhao";
      # Enable IMAP/SMTP in 163 webmail and sign in with an app password.
      imap = {
        host = "imap.163.com";
        port = 993;
        authentication = "plain";
        tls.enable = true;
      };
      smtp = {
        host = "smtp.163.com";
        port = 465;
        authentication = "plain";
        tls.enable = true;
      };
    }
  ];
  enabledAccounts = builtins.filter (account: account.address != "") mailAccounts;
in
{
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      accountsOrder = map (account: account.name) enabledAccounts;
      settings = {
      };
    };
  };

  accounts.email.accounts = builtins.listToAttrs (
    lib.imap0 (index: account: {
      inherit (account) name;
      value = (builtins.removeAttrs account [ "name" ]) // {
        primary = index == 0;
        userName = account.address;
        realName = if account.realName == "" then account.address else account.realName;
        thunderbird.enable = true;
      };
    }) enabledAccounts
  );

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "message/rfc822"
    "x-scheme-handler/mailto"
  ] (_: "thunderbird.desktop");
}
