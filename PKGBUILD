# $Id: $
# Maintainer: Giovanni Scafora <giovanni@archlinux.org>

pkgname=ckit
pkgver=0.531
_commit=4fe8779
pkgrel=1
pkgdesc="Construction Kit - An unofficial Arch Linux repository manager"
arch=('i686' 'x86_64')
url="http://www.deelab.org/ckit/ckit.html"
license=('GPL' 'LGPL' 'RUBY')
depends=('ruby')
makedepends=('git')
backup=(etc/ckit/ckit.conf)
provides=('ckit')
conflicts=('ckit')
source=("http://download.github.com/rivaldid-$pkgname-$_commit.tar.gz")
md5sums=('506ac08554a02e3c76b20127fdaa615d')

build() {
  cd "$srcdir/rivaldid-$pkgname-$_commit"

  ruby setup.rb config --sysconfdir="/etc/ckit" || return 1
  ruby setup.rb setup || return 1
  ruby setup.rb install --prefix="${pkgdir}" || return 1
}
