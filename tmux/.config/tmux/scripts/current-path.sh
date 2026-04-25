#!/usr/bin/env sh

path=${1:-"$PWD"}
path=${path%/}

basename "$path"
