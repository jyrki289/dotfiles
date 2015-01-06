#!/bin/bash

# Get system info
SYSTEM=$(uname -s)

#### Hook into dotfiles checkout from the actual dot files
pushd ~/.dotfiles
cp screenrc ~/.screenrc
cp hgrc     ~/.hgrc
# (Allow site-specific customizations in ~/.bash_profile, etc)
mv ~/.bashrc            ~/.bashrc.bak
cp bashrc_stub.sh       ~/.bashrc
mv ~/.bash_profile      ~/.bash_profile.bak
cp bash_profile.sh      ~/.bash_profile
mv ~/.emacs             ~/.emacs.bak
cp emacs_stub.el        ~/.emacs
popd

mkdir -p ~/bin

### Install packages
pushd ~/.dotfiles/Packages/
tar xvfz autojump-release-v21.7.1.tar.gz
cd autojump-release-v21.7.1
./install.sh --local
popd
