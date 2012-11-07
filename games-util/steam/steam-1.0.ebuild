# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils

DESCRIPTION="Steam for Linux"
HOMEPAGE="http://store.steampowered.com/"
SRC_URI="http://media.steampowered.com/client/installer/${PN}.deb"

LICENSE="custom"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

src_unpack() {
	cd "$WORKDIR"
	echo "ohhai $(pwd)" 1>&2
	unpack $A
	tar xf data.tar.gz
	mkdir -p $S
}

src_install() {
	mv $WORKDIR/usr $D/
	# Replace [ ] with [[ ]] in /usr/bin/steam
	sed "s/\[/\[\[/g" -i $D/usr/bin/steam
	sed "s/\]/\]\]/g" -i $D/usr/bin/steam
}
