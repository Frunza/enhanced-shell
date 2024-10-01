#!/bin/sh

# Exit immediately if a simple command exits with a nonzero exit value
set -e

stow --adopt --override='.*' --ignore='.DS_Store' -v dotfiles
