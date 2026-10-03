{ host, ... }:

{
  networking.hostName = host.name;
}
