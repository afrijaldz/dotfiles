#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                                                        # dotfiles directory
olddir=~/dotfiles_old                                                 # old dotfiles backup directory
files="bashrc vimrc vim zshrc vscode oh-my-zsh tmux.conf config/nvim" # list of files/folders to symlink in homedir

rm -rf ~/.local/share/nvim ~/.cache/nvim

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
	echo "Moving any existing dotfiles from ~ to $olddir"
	mv ~/.$file ~/dotfiles_old
	echo "Creating symlink to $file in home directory."
	ln -s $dir/.$file ~/.$file
done

curl -fLo ~/dotfiles/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
