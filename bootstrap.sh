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
pushd ~/.dotfiles/Packages
tar xvfz autojump_v15.tar.gz
# Manually install autojump, as its installer is stupid and wants to
# put things in /etc instead of just the user dir
mkdir -p ~/.autojump
cp autojump_v15/autojump   ~/bin
cp autojump_v15/jumpapplet ~/bin
cp autojump_v15/autojump.{sh,bash,zsh} ~/.autojump

popd
