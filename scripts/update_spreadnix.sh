#!/usr/bin/env bash

rm ~/workspaces/spreadconfig/configuration.nix
rm ~/workspaces/spreadconfig/flake.lock
rm ~/workspaces/spreadconfig/flake.nix
rm ~/workspaces/spreadconfig/home.nix
rm ~/workspaces/spreadconfig/hardware-configuration.nix
rm -rf ~/workspaces/spreadconfig/secrets
rm -rf ~/workspaces/spreadconfig/spreadconfig

cp -rf /etc/nixos/* ~/workspaces/spreadconfig/
