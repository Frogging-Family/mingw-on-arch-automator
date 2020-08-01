# Mingw on Arch automator

Automate the (annoying) installation of mingw on Arch and Arch-based distros.

You'll find two switches in the script to enable dwarf2 exceptions and/or disable fortran.

Using dwarf2 exceptions instead of sjlj exceptions provides a large performance boost to 32-bit DXVK and is enabled by default.

**Packages that will be installed :**
- cloog or cloog-git
- mingw-w64-binutils
- mingw-w64-headers
- mingw-w64-headers-bootstrap (also removed in the process)
- mingw-w64-gcc-base (also removed in the process)
- mingw-w64-crt
- mingw-w64-winpthreads
- mingw-w64-gcc

If you set _sdlandco to "true", you'll also get the following (disabled by default) :
- mingw-w64-pkg-config
- mingw-w64-configure
- mingw-w64-sdl2

**Temporary Fix for general authorizaion error in retrieving gpg keys (#1)

- Open a terminal and make sure your in your home directory
- cd to .gnupg, open gpg.conf in a text editor or commandline editor
- type in 'keyserver' and then a space
- locate a keyserver on https://sks-keyservers.net/overview-of-pools.php and copy/paste the address into the text editor/commandline editor after keyserver
- Save the file
- Try to import your keys again until it doesnt fail

**PGP keys importation might fail/timeout sometimes (dodgy servers, I assume), so if you don't see a successful key importation after ~10 seconds at worst or if the compilation fails with a PGP key related error, you can try to import them manually:**
```
gpg --recv-keys 13FCEF89DD9E3C4F
gpg --recv-keys 93BDB53CD4EBC740
gpg --recv-keys A328C3A2C3C45C06
```
Here's more detail about the keys:
`3A24BC1E8FB409FA9F14371813FCEF89DD9E3C4F` # Nick Clifton <nickc@redhat.com>
`CAF5641F74F7DFBA88AE205693BDB53CD4EBC740` # Jonathan Yong <jon_y@users.sourceforge.net>
`33C235A34C46AA3FFB293709A328C3A2C3C45C06` # Jakub Jelinek <jakub@redhat.com>

## If you don't necessarily want pacman packages and would prefer a "portable" toolchain:
A more powerful and configurable GCC/Mingw building tool (working cross-distro) is also available here https://github.com/Frogging-Family/mostlyportable-gcc
