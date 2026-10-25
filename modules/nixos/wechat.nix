{ ... }:

{
  # Allow WeChat chat-history imports from private IPv4 networks.
  networking.firewall.extraInputRules = ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport 8015 accept comment "WeChat chat-history import"
  '';
}
