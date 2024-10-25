#!/usr/bin/env zsh

sudo -k
if ! sudo -v; then
  echo "Wrong password"
  exit 1
fi

# sudo apt install dconf-gsettings-backend libacl1 libasound2t64 libc6 libcairo2 libdbus-1-3 libfontconfig1 libfreetype6 libgccjit0 libgdk-pixbuf-2.0-0 libgif7 libglib2.0-0t64 libgmp10 libgnutls30t64 libgpm2 libgtk-3-0t64 libharfbuzz0b libjansson4 libjpeg62-turbo liblcms2-2 libotf1 libpango-1.0-0 libpng16-16t64 librsvg2-2 libselinux1 libsqlite3-0 libsystemd0 libtiff6 libtinfo6 libtree-sitter0 libwebpdecoder3 libwebpdemux2 libxml2 zlib1g texinfo libmagickwand-dev libgnutls28-dev

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
