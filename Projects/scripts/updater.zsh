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

(
    _update_neovim() {
        local neovim_dir="$HOME/Projects/src-builds/neovim"

        if [[ ! -d "$neovim_dir" ]]; then
			_pwarn "Neovim directory does not exist. Cloning from GitHub..."
			git clone "https://github.com/neovim/neovim" "$neovim_dir" || {
				_perr "Couldn't install neovim"
				return 1
			}
        fi

        pushd "$neovim_dir" || {
        _perr "Could not change to neovim directory"
        return 1
        }
        {
			make clean &&
			make distclean &&
			git pull --recurse-submodules --all &&
			make CMAKE_BUILD_TYPE=Release &&
			sudo make install
			# pushd build &&
			# cpack -G DEB &&
			# sudo dpkg -i nvim-linux64.deb &&
			# popd
        } || {
            _perr "Could't install neovim"
            return 1
        }
        popd
    }
    _update_neovim
    unset _update_neovim
) || _perr "Updating and compiling neovim failed. Please install it manually."

(
    if ! command -v pnpm &> /dev/null; then
        _perr "Error: pnpm not installed"
        if ! command curl -fsSL https://get.pnpm.io/install.sh | sh -; then
            _perr "Error: Failed to install pnpm. Please check your network connection and try again"
            exit 1
        else
            sed -i '/^# pnpm$/,/^# pnpm end$/d' "${ZDOTDIR:-$HOME}/.zshrc"
        fi
    fi

    if ! pnpm add -g pnpm@latest; then
        _perr "Couldn't add pnpm"
        exit 1
    fi
    if ! pnpm up -g -L; then
        _perr "Couldn't update pnpm"
        exit 1
    fi
) || _perr "Updating pnpm failed. If not installed, run: curl -fsSL https://get.pnpm.io/install.sh | sh -. Then run:\npnpm add -g pnpm@latest\npnpm up -g -L"

(
	if ! command -v uv &> /dev/null; then
		_perr "Error: uv not installed"
	  if ! command curl -LsSf https://astral.sh/uv/install.sh | sh -; then
		  _perr "Error: Failed to install pnpm. Please check your network connection and try again"
		  exit 1
	  fi
	fi

	if ! uv self update; then
		_perr "Couldn't upgrade uv itself"
		exit 1
	fi

	if ! uv generate-shell-completion zsh >| $ZDOTDIR/.zfunc/_uv; then
	  _perr "Couldn't generate ruff completions"
	  exit 1
	fi

	if ! uv tool upgrade --all; then
		_perr "Couldn't upgrade uv packages"
		exit 1
	fi

	if ! ruff generate-shell-completion zsh >| $ZDOTDIR/.zfunc/_ruff; then
	  _perr "Couldn't generate ruff completions"
	  exit 1
	fi
) || _perr "Updating uv and it's packages failed. To install, run: curl -LsSf https://astral.sh/uv/install.sh | sh -, then run:\nuv self update\n uv generate-shell-completion zsh >| \$ZDOTDIR/.zfunc/_uv\n uv tool upgrade --all\n ruff generate-shell-completion zsh >| \$ZDOTDIR/.zfunc/_ruff"

(
	if ! command -v opam &> /dev/null; then
		_perr "Error: opam not installed"
		exit 1
	fi

	if ! { opam update && opam upgrade -y }; then
	  _perr "Couldn't upgrade opam packages"
	  exit 1
	fi
) || _perr "Updating opam, ocaml and it's packages failed. Install opam, and then run: opam update && opam upgrade -y"

(
	if ! command -v mise &> /dev/null; then
		_perr "Error: mise not installed"
		exit 1
	fi

	eval "$(command mise activate zsh)"

	if ! mise self-update --yes; then
		_perr "Couldn't self-update mise"
		exit 1
	fi

	if ! mise completion zsh >| $ZDOTDIR/.zfunc/_mise; then
	  _perr "Couldn't generate mise completions"
	  exit 1
	fi

	if ! mise up --yes; then
		_perr "Couldn't upgrade mise packages"
		exit 1
	fi
) || _perr "Updating mise failed. Install it if it isn't, then run: mise self-update --yes\nmise completion zsh >| \$ZDOTDIR/.zfunc/_mise\nmise up --yes"

eval "$(command mise activate zsh)"

(
	if ! command -v rustup &> /dev/null; then
		_perr "Error: rustup not installed"
		exit 1
	fi

	if ! rustup update; then
		_perr "Couldn't upgrade rustup"
		exit 1
	fi

	if ! rustup completions zsh >| $ZDOTDIR/.zfunc/_rustup; then
	  _perr "Couldn't generate rustup completions"
	  exit 1
	fi

	if ! rustup completions zsh cargo >| $ZDOTDIR/.zfunc/_cargo; then
	  _perr "Couldn't generate cargo completions"
	  exit 1
	fi
) || _perr "Couldn't upgrade rustup. If not installed, run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh. Otherwise, run:\nrustup update\nrustup completions zsh >| \$ZDOTDIR/.zfunc/_rustup\nrustup completions zsh cargo >| \$ZDOTDIR/.zfunc/_cargo"

(
	if ! cargo install-update -a -g; then
		_pwarn "cargo install-update was not there, probably no cargo package is there too!"
		if ! cargo install --git https://github.com/nabijaczleweli/cargo-update.git; then
		  _perr "Error: Failed to install cargo-update. Please check your network connection and try again"
		  exit 1
		fi
		if ! cargo install-update -a -g; then
			_perr "Couldn't upgrade cargo packages"
			exit 1
		fi
	fi
) || _perr "Cargo packages can't be updated. Install cargo update using:\ncargo install --git https://github.com/nabijaczleweli/cargo-update.git\ncargo install-update -a -g"


if ! deno completions zsh >| $ZDOTDIR/.zfunc/_deno; then
	_perr "Couldn't generate deno completions"
fi

if ! bun completions >| $ZDOTDIR/.zfunc/_bun; then
	_perr "Couldn't generate bun completions"
fi

(
	if ! command -v micromamba &> /dev/null; then
	  if ! "${SHELL}" <(curl -L micro.mamba.pm/install.sh); then
		  _perr "Error: Failed to install micromamba. Please check your network connection and try again"
		  exit 1
	  fi
	  _pwarn "micromamba was not there, probably no env is there too!"
	fi

	eval "$(micromamba shell hook --shell zsh)"

	if ! micromamba self-update; then
		_perr "Couldn't upgrade micromamba"
		exit 1
	fi

	if ! micromamba shell hook --shell zsh >| $ZDOTDIR/.zfunc/_mamba; then
	  _perr "Couldn't generate mamba completions"
	  exit 1
	fi

	for env in $(micromamba env list | tail -n +4 | awk '{print $1}'); do
		   { micromamba activate "$env" && micromamba update --all --yes && micromamba deactivate } || {
			   _perr "Failed to upgrade $env"
				exit 1
			}
	done
) || _perr 'Updating micromamba packages failed: Install it using "${SHELL}" <(curl -L micro.mamba.pm/install.sh). Then run: micromamba self-update, then activate and update every environment'

if command -v tldr &> /dev/null; then
    tldr --update || _perr "Couldn't update tldr cache, run tldr --update"
fi


if command -v getnf &> /dev/null; then
    getnf -U || _perr "Couldn't update fonts, run getnf -U"
fi

_update_fzf() {
    local fzf_dir="$XDG_DATA_HOME/fzf"

    if [[ ! -d "$fzf_dir" ]]; then
        _pwarn "Fzf directory does not exist. Cloning from GitHub..."
        git clone "https://github.com/junegunn/fzf" "$fzf_dir" || {
            _perr "Couldn't install fzf"
            return 1
        }
    fi
    pushd "$fzf_dir" || {
        _perr "Could not change to fzf directory"
        return 1
    }
	git pull --recurse-submodules --all || {
		_perr "Couldn't update fzf"
		return 1
	}
    [[ -f bin/fzf ]] && rm bin/fzf || {
        _perr "Could not delete fzf binary"
        return 1
    }
    ./install --bin || {
        _perr "Could not install fzf binary"
        return 1
    }
    popd
}
_update_fzf
unset _update_fzf

_update_emsdk() {
    local emsdk_dir="$XDG_DATA_HOME/emsdk"

    if [[ ! -d "$emsdk_dir" ]]; then
        _pwarn "Emsdk directory does not exist. Cloning from GitHub..."
        git clone --recursive https://github.com/emscripten-core/emsdk.git "$emsdk_dir" || {
            _perr "Couldn't install emsdk"
            return 1
        }
    fi
    pushd "$emsdk_dir" || {
        _perr "Could not change to emsdk directory"
        return 1
    }
	git pull --recurse-submodules --all || {
		_perr "Couldn't update emsdk"
		return 1
	}
    ./emsdk install tot || {
        _perr "Could not install tot emsdk"
        return 1
    }
    ./emsdk activate tot || {
        _perr "Could not activate tot emsdk"
        return 1
    }
    popd
}
_update_emsdk
unset _update_emsdk

yes | mix archive.install hex phx_new || {
    _perr "Could not update mix packages"
    exit 1
}


if ! git -C $ZDOTDIR submodule update --remote --merge; then
    _perr "Could not update zsh plugins"
    exit 1
fi

if [[ -f /usr/lib/kitty/shell-integration/zsh/completions/_kitty ]]; then
	cp "/usr/lib/kitty/shell-integration/zsh/completions/_kitty" "$ZDOTDIR/.zfunc/_kitty"
fi

unset _pok
unset _perr
unset _pwarn

rm -fr $ZDOTDIR/.zcompdump $ZDOTDIR/.zcompdump.zwc $ZDOTDIR/.zcompcache
