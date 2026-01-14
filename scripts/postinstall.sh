#!/usr/bin/env bash

systemctl --user add-wants niri.service waybar.service
systemctl --user add-wants niri.service mako.service
