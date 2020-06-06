#!/bin/bash

# Created by: Tk-Glitch <ti3nou at gmail dot com>

cat << 'EOM'
       .---.`               `.---.
    `/syhhhyso-           -osyhhhys/`
   .syNMdhNNhss/``.---.``/sshNNhdMNys.
   +sdMh.`+MNsssssssssssssssNM+`.hMds+
   :syNNdhNNhssssssssssssssshNNhdNNys:
    /ssyhhhysssssssssssssssssyhhhyss/
    .ossssssssssssssssssssssssssssso.
   :sssssssssssssssssssssssssssssssss:
  /sssssssssssssssssssssssssssssssssss/
 :sssssssssssssoosssssssoosssssssssssss:
 osssssssssssssoosssssssoossssssssssssso
 osssssssssssyyyyhhhhhhhyyyyssssssssssso
 /yyyyyyhhdmmmmNNNNNNNNNNNmmmmdhhyyyyyy/
  smmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmms
   /dNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNd/
    `:sdNNNNNNNNNNNNNNNNNNNNNNNNNds:`
       `-+shdNNNNNNNNNNNNNNNdhs+-`
             `.-:///////:-.`

EOM

export BUILDDIR= # Override makepkg BUILDDIR path and use PKGBUILDs dirs instead

_arg1="$1"
_where=$PWD
_fortran=false
_win32threads=false
_cloog_git=false
_pgp_auto=true

if [ "$1" = "nopgp" ]; then
  _pgp_auto=false
fi

_sdlandco=false

# Set to true to clean sources after building - If set to false, you'll be prompted about it
_NUKR=false

 echo '##################################################################'
 echo ''
 echo 'Mingw on arch automator will install mingw for you. The automation'
 echo 'process needs to use pacman, so your password will be required.'
 echo ''
 echo '####################################TkG##########was##########here'

if [ $_NUKR == "false" ]; then
  echo ''
  echo -e "  \033[1mDo you want to delete build/src dirs before & after building?\033[0m"
  echo -e "    \033[1m- Doing so will ensure you're running the latest version.\033[0m"
  echo "    - Default (No) will keep sources/tarballs and packages around,"
  echo "      without updating existing PKGBUILDs if any."
  read -rp "  N/y: " _clean_mingw;
  if [ "$_clean_mingw" == "y" ]; then
    _NUKR=true
    # cleanup
    echo "Cleaning up"
    rm -rf mingw-w64-*
    rm -rf cloo*
    rm -rf osl
    rm -rf isl
  fi
fi

_mingwloop() {
  git clone https://aur.archlinux.org/$_AURPKGNAME.git
  cd $_AURPKGNAME
  rm *.pkg.* # Delete package if exists
  if [ "$_AURPKGNAME" == "mingw-w64-binutils" ]; then
    wget -c -O binutils234.binutilspatch https://sourceware.org/bugzilla/attachment.cgi?id=12545
    patch PKGBUILD << 'EOM'
@@ -9,14 +9,17 @@ groups=('mingw-w64-toolchain' 'mingw-w64')
 depends=('zlib')
 options=('!libtool' '!emptydirs')
 validpgpkeys=('3A24BC1E8FB409FA9F14371813FCEF89DD9E3C4F')  # Nick Clifton (Chief Binutils Maintainer) <nickc@redhat.com>
-source=("https://ftp.gnu.org/gnu/binutils/binutils-${pkgver}.tar.gz"{,.sig})
+source=("https://ftp.gnu.org/gnu/binutils/binutils-${pkgver}.tar.gz"{,.sig}
+        "binutils234.binutilspatch")
 sha256sums=('53537d334820be13eeb8acb326d01c7c81418772d626715c7ae927a7d401cab3'
-            'SKIP')
+            'SKIP'
+            '870e0dfb3cea709dda32a864b6d082d38e8b7890b7e18206b8a826ad0d328eae')
 
 _targets="i686-w64-mingw32 x86_64-w64-mingw32"
 
 prepare() {
   cd "$srcdir"/binutils-${pkgver}
+  patch -Np1 < "$srcdir/binutils234.binutilspatch"
   #do not install libiberty
   sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
   # hack! - libiberty configure tests for header files using "$CPP $CPPFLAGS"
EOM
  fi
  if [ "$_win32threads" == "true" ]; then
    sed -i "s/threads=posix/threads=win32/g" PKGBUILD
  fi
  if [ "$_AURPKGNAME" == "mingw-w64-gcc" ] && [ $_fortran == "false" ]; then
    #no fortran
    patch PKGBUILD << 'EOM'
@@ -36,7 +36,7 @@
     "$srcdir"/gcc/configure --prefix=/usr --libexecdir=/usr/lib \
         --target=${_arch} \
         --with-bugurl=https://bugs.archlinux.org/ \
-        --enable-languages=c,lto,c++,ada,objc,obj-c++,fortran \
+        --enable-languages=c,lto,c++,ada,objc,obj-c++ \
         --enable-shared --enable-static \
         --enable-threads=posix --enable-fully-dynamic-string \
         --enable-libstdcxx-time=yes --enable-libstdcxx-filesystem-ts=yes \
@@ -55,7 +55,7 @@
     make DESTDIR="$pkgdir" install
     ${_arch}-strip "$pkgdir"/usr/${_arch}/lib/*.dll
     strip "$pkgdir"/usr/bin/${_arch}-*
-    strip "$pkgdir"/usr/lib/gcc/${_arch}/${pkgver}/{cc1*,collect2,gnat1,f951,lto*}
+    strip "$pkgdir"/usr/lib/gcc/${_arch}/${pkgver}/{cc1*,collect2,gnat1,lto*}
     ln -s ${_arch}-gcc "$pkgdir"/usr/bin/${_arch}-cc
     # mv dlls
     mkdir -p "$pkgdir"/usr/${_arch}/bin/
EOM
  fi
  if [[ "$_arg1" == "-f" ]] || [[ "$_arg1" == "--force" ]]; then
    makepkg -csi --noconfirm --force
  else
    makepkg -csi --noconfirm
  fi
  if [ "$_AURPKGNAME" == "mingw-w64-winpthreads" ]; then
    libtool --finish /usr/x86_64-w64-mingw32/lib
  fi
  cd $_where
}

# PGP keys
if [ $_pgp_auto == "true" ]; then
  echo -e "\nAttempting to add PGP keys... The keyserver can be unreliable. If it seems stuck, please try re-running the script a few times.\n"
  gpg --recv-keys 13FCEF89DD9E3C4F
  gpg --recv-keys 93BDB53CD4EBC740
  gpg --recv-keys A328C3A2C3C45C06
fi

sudo pacman -Rscnd mingw-w64 --noconfirm

if [ ! -e ../wine-tkg-git/BIG_UGLY_FROGMINER ]; then
  trap "exit" INT TERM
  trap "kill 0" EXIT
fi

sudo -v || exit $?
sleep 1
while true; do
  sleep 60
  sudo -nv
done 2>/dev/null &

# cloog git - If the usual cloog package fails with mingw, you'll need -git
if [ $_cloog_git == "true" ]; then
  sudo pacman -Rscnd cloog --noconfirm
  _AURPKGNAME=cloog-git
  _mingwloop || exit 1
else
  sudo pacman -Rscnd cloog-git --noconfirm

  # osl - isl - cloog
  _AURPKGS=(osl isl cloog)
  for _AURPKGNAME in "${_AURPKGS[@]}"; do
    _mingwloop || exit 1
  done
fi

# mingw-w64-binutils - mingw-w64-headers - mingw-w64-headers-bootstrap - mingw-w64-gcc-base - mingw-w64-crt
_AURPKGS=(mingw-w64-binutils mingw-w64-headers mingw-w64-headers-bootstrap mingw-w64-gcc-base mingw-w64-crt)
for _AURPKGNAME in "${_AURPKGS[@]}"; do
  _mingwloop || exit 1
done

# remove mingw-w64-headers-bootstrap
sudo pacman -Rdd --noconfirm mingw-w64-headers-bootstrap

# mingw-w64-winpthreads
_AURPKGNAME=mingw-w64-winpthreads
_mingwloop || exit 1

# remove mingw-w64-gcc-base
sudo pacman -Rdd --noconfirm mingw-w64-gcc-base

# mingw-w64-gcc
_AURPKGNAME=mingw-w64-gcc
_mingwloop || exit 1

if [ $_sdlandco == "true" ]; then
  # mingw-w64-pkg-config - mingw-w64-configure - mingw-w64-cmake - mingw-w64-sdl2
  _AURPKGS=(mingw-w64-pkg-config mingw-w64-configure mingw-w64-cmake mingw-w64-sdl2)
  for _AURPKGNAME in "${_AURPKGS[@]}"; do
    _mingwloop || exit 1
  done
fi

if [ $_NUKR == "true" ]; then
  # cleanup
  echo "Cleaning up..."
  rm -rf mingw-w64-*
  rm -rf cloo*
  rm -rf osl
  rm -rf isl
fi

echo ""
echo "mingw-on-arch done !" && exit 0
