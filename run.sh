#!/bin/bash

if [ $# -eq 0 ]; then
	"/Users/paul/Documents/Programming/Game/moai-sdk/bin/osx/moai" "config.lua" "main.lua"
else
	"/Users/paul/Documents/Programming/Game/moai-sdk/bin/osx/moai" $@
fi
