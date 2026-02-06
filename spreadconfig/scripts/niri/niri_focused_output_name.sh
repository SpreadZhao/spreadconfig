#!/usr/bin/env bash

niri msg -j focused-output | jq -r '.name'
