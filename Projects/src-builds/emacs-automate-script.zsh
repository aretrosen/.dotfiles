#!/usr/bin/env zsh

sudo -k
if ! sudo -v; then
  echo "Wrong password"
  exit 1
fi

# sudo apt install libgnutls28-dev libmagickwand-dev 

pushd emacs-bleeding
make extraclean
popd

pushd emacs
git pull --recurse-submodules --all
./autogen.sh
popd

pushd emacs-bleeding
../emacs/configure --with-mailutils --with-sound=alsa --with-pdumper=yes --with-imagemagick --with-tree-sitter --with-pgtk --with-native-compilation=aot --without-compress-install CXXFLAGS="-O2 -g3 -mtune=native -march=native -Wall -Wextra -Wformat=2 -Wtrampolines -Wbidi-chars=any -Werror=format-security -Werror=implicit -Werror=incompatible-pointer-types -Werror=int-conversion -fhardened -fstrict-flex-arrays=3 -fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing -fexceptions -Wl,-z,nodlopen -Wl,-z,noexecstack" CFLAGS="-O2 -g3 -mtune=native -march=native -Wall -Wextra -Wformat=2 -Wtrampolines -Wbidi-chars=any -Werror=format-security -Werror=implicit -Werror=incompatible-pointer-types -Werror=int-conversion -fhardened -fstrict-flex-arrays=3 -fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing -fexceptions -Wl,-z,nodlopen -Wl,-z,noexecstack" TREE_SITTER_LIBS="-L/usr/local/lib -ltree-sitter" TREE_SITTER_CFLAGS="-isystem /usr/local/include"

make -j$(nproc)
sudo make -j$(nproc) install
popd
