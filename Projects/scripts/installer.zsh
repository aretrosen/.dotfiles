#!/usr/bin/env zsh

echo "Password: "
read -s _my_pass_word

_perr() {
	echo "\e[31m$1\e[0m"
}

_pok() {
	echo "\e[32m$1\e[0m"
}

_clean_up() {
	unset _pok
	unset _perr
	unset _my_pass_word
}

trap _clean_up EXIT SIGINT SIGTERM SIGHUP

if ! command -v pnpm &> /dev/null; then
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
if ! pnpm add -g @biomejs/biome@latest; then
	_perr "Couldn't add pnpm"
	exit 1
fi

if ! command -v pipx &> /dev/null; then
	_perr "Error: pipx not installed. Need to do it manually"
	exit 1
fi

if ! pipx install ruff; then
	_perr "Couldn't add ruff"
	exit 1
fi

if ! pipx install uv; then
	_perr "Couldn't add uv"
	exit 1
fi

if ! pipx install git+https://github.com/ansible/ansible; then
	_perr "Couldn't add ansible"
	exit 1
fi

if ! pipx inject ansible-core --include-apps git+https://github.com/ansible/ansible-lint; then
	_perr "Couldn't add ansible-lint"
	exit 1
fi

if ! pipx inject ansible-core jmespath; then
	_perr "Couldn't add jmespath"
	exit 1
fi

if ! command -v opam &> /dev/null; then
	if ! command bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"; then
		_perr "Error: opam could not be installed"
		exit 1
	fi
	exit 0
fi

opam install base coq coqide core ocaml-lsp-server ocamlformat odoc
