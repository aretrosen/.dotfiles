#!/usr/bin/env zsh

sudo -k
if ! sudo -v; then
    echo "Wrong password"
    exit 1
fi

pushd tree-sitter
git pull --recurse-submodules --all
make PREFIX=/usr/local LDFLAGS="-flto" CFLAGS="-flto" CXXFLAGS="-flto"
pushd cli
cargo build --release
popd
sudo make PREFIX=/usr/local DESTDIR= install
sudo install -Dt /usr/local/bin target/release/tree-sitter
popd
