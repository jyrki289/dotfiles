## First, source dotfiles settings
source ~/.dotfiles/bashrc.sh

## Now, site-specific configurations
if [ -f ~/.bashrc_site.bash ]; then
    source ~/.bashrc_site.bash
fi