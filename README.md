          ___           ___           ___           ___       ___ 
         /\  \         /\__\         /\  \         /\__\     /\__\
        /::\  \       /:/  /        /::\  \       /:/  /    /:/  /
       /:/\ \  \     /:/__/        /:/\:\  \     /:/  /    /:/  / 
      _\:\~\ \  \   /::\  \ ___   /::\~\:\  \   /:/  /    /:/  /  
     /\ \:\ \ \__\ /:/\:\  /\__\ /:/\:\ \:\__\ /:/__/    /:/__/   
     \:\ \:\ \/__/ \/__\:\/:/  / \:\~\:\ \/__/ \:\  \    \:\  \   
      \:\ \:\__\        \::/  /   \:\ \:\__\    \:\  \    \:\  \  
       \:\/:/  /        /:/  /     \:\ \/__/     \:\  \    \:\  \ 
        \::/  /        /:/  /       \:\__\        \:\__\    \:\__\
         \/__/         \/__/         \/__/         \/__/     \/__/


I'm using most of the time the zsh shell, but on few server where I can't 
install zsh (or where I do not feel the need to install it), I'm using what's 
available, most of the time bash.
This repository contains all my sh(es) configuration file (zsh, bash, ...).

## Basic information

The idea is simple : Share the most thing between shells and try to be posix
compliant on common file.

* `$HOME/.shenv` is sourced by any shell (and at login via .profile). It contains the
  ssh-agent initialization and env stuff.
* Most of the alias are shared between shells.

## Notes

I've been a user of [oh-my-zsh][ohmyzsh] for few years now but I do agree with
[Vincent Bernat][vincentbernat] : 

> My Opinion is that you can't have an universal `.zshrc`.

That's why I'm currently ditching [oh-my-zsh][ohmyzsh] from my configuration.
Still it's a wonderful piece of software and a very active zsh community. There
is a lot of good ideas there, source of inspiration.

[ohmyzsh]: https://github.com/robbyrussell/oh-my-zsh
[vincentbernat]: http://vincent.bernat.im
