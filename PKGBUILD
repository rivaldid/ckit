# $Id: $
# Maintainer: Giovanni Scafora <giovanni@archlinux.org>

pkgname=ckit-git
pkgver=20100202
pkgrel=1
pkgdesc="Construction Kit - An unofficial Arch Linux repository manager"
arch=('i686' 'x86_64')
url="http://www.deelab.org/ckit"
license=('GPL')
depends=('ruby')
makedepends=('git')
backup=(etc/conf/ckit.conf)
provides=('ckit')
conflicts=('ckit')

_gitroot="git://github.com/rivaldid/ckit.git"
_gitname="ckit-git"

build() {
  cd "$srcdir"
  msg "Connecting to GIT server...."

  if [ -d $_gitname ] ; then
    cd $_gitname && git pull origin
    msg "The local files are updated."
  else
    git clone $_gitroot $_gitname
  fi

  msg "GIT checkout done or server timeout"
  msg "Starting make..."

  rm -rf "$srcdir/$_gitname-build"
  git clone "$srcdir/$_gitname" "$srcdir/$_gitname-build"
  cd "$srcdir/$_gitname-build"

  ruby setup.rb config --sysconfdir="/etc/conf" || return 1
  ruby setup.rb setup || return 1
  ruby setup.rb install --prefix="${pkgdir}" || return 1
}
