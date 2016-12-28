#!/bin/bash
directory=$(dirname "$BASH_SOURCE")
makejs=$directory
makejs+="/make.js"
node "$makejs" "$@"