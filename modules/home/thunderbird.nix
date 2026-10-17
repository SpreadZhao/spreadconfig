{ lib, ... }:

let
  # 填写 address 即启用账号；realName 留空时使用邮箱地址作为发件人名称。
  # 列表中第一个已填写的账号是默认发信账号，可调整顺序。
  # 密码、163 授权码和 OAuth 登录由 Thunderbird 管理，不写入 Nix 配置。
  mailAccounts = [
    {
      name = "Outlook SpreadZhao";
      address = "spreadzhao@outlook.com";
      realName = "Spread Zhao";
      # Outlook.com / Hotmail 个人邮箱；网页设置中需允许 IMAP 访问。
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
      # Home Manager 的 Gmail 预设配置 IMAP/SMTP、TLS 和 OAuth2。
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
      # 在网易网页邮箱开启 IMAP/SMTP；首次连接输入客户端授权码。
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
        # 绕过 Outlook IMAP 在部分 IPv6 连接下的认证失败，仅影响 Thunderbird。
        "network.dns.disableIPv6" = true;
        "mailnews.display.html_as" = 0;
        "mailnews.display.prefer_plaintext" = false;
        "mail.inline_attachments" = true;
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
}
