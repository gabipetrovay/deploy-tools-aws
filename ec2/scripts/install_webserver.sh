#!/usr/bin/env bash

readonly node_required_version="10"

function install_node {
  # Source: https://github.com/nodesource/distributions#installation-instructions
  curl -sL https://deb.nodesource.com/setup_${node_required_version}.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

if [ "1" -eq $(which node > /dev/null; echo $?) ]; then
  install_node
else
  node_version="$(node --version)"
  node_version="${node_version%%.*}"
  node_version="${node_version#v}"
  if [ "${node_version}" -ne "${node_required_version}" ]; then
    install_node
  fi
fi
