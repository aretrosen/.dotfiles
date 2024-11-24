#!/usr/bin/env zsh

sudo -k
if ! sudo -v; then
    echo "Wrong password"
    exit 1
fi

_perr() {
    echo "\e[31m$1\e[0m"
}

_pwarn() {
    echo "\e[33m$1\e[0m"
}

_pok() {
    echo "\e[32m$1\e[0m"
}

sudo apt-file update || {
    _perr "Could not update apt-file database"
    exit 1
}

if type tldr &> /dev/null; then
    tldr --update || _perr "Couldn't update tldr cache, run tldr --update"
fi

if type getnf &> /dev/null; then
    getnf -U || _perr "Couldn't update fonts, run getnf -U"
fi

yes | mix archive.install hex phx_new || {
    _perr "Could not update mix packages"
    exit 1
}

if ! git -C $ZDOTDIR submodule update --remote --merge; then
    _perr "Could not update zsh plugins"
    exit 1
fi

unset _pok
unset _perr
unset _pwarn

rm -fr $ZDOTDIR/.zcompdump $ZDOTDIR/.zcompdump.zwc $ZDOTDIR/.zcompcache
