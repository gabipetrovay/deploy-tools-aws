#!/usr/bin/env bash

readonly dirname="$(dirname $0)"

# bash customization
sed -i 's/ls -laF/ls -lF/' ~/.bashrc
sed -i 's/ls -A/ls -alF/' ~/.bashrc

# Vim customization
if [ ! -f ~/.vimrc ]; then
  cp "${dirname}/files/vimrc" ~/.vimrc
fi

# ssh config
# add github to the known hosts
ssh -q -o StrictHostKeyChecking=no -T git@github.com > /dev/null 2>&1

# sshd service configuration
sudo sed -i 's/ LC_\*$/ LC_* GIT_*/' /etc/ssh/sshd_config
sudo service sshd restart

# Git configuration
git config --global push.default simple

# general distribution updates
sudo apt-get update > /dev/null

