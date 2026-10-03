#!/usr/bin/env bash

pgrep -f "foot --server" > /dev/null || foot --server
