# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

ABBREV="doublecmd"
DESCRIPTION="Cross Platform file manager."
HOMEPAGE="http://${ABBREV}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${ABBREV}/${ABBREV}-${PV}-src.tar.gz"
S="${WORKDIR}/${ABBREV}-${PV}"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE="qt4 gtk"

REQUIRED_USE=" ^^ ( qt4 gtk )"

RDEPEND="sys-apps/dbus
	dev-libs/glib
	sys-libs/ncurses
	x11-libs/libX11
	gtk? ( x11-libs/gtk+:2 )
	qt4? ( >=dev-qt/qtpascal-2.5 )"

DEPEND="${RDEPEND}
	>=dev-lang/lazarus-1.2"

src_prepare(){
    use qt4 && export lcl="qt" || export lcl="gtk2"
    use amd64 && export CPU_TARGET="x86_64" || export CPU_TARGET="i386"

    export lazpath="/usr/share/lazarus"

    if use qt4 ; then
	cp /usr/lib/qt4/libQt4Pas.so plugins/wlx/WlxMplayer/src/
	cp /usr/lib/qt4/libQt4Pas.so src/
    fi

    find ./ -type f -name "build.sh" -exec sed -i 's#$lazbuild #$lazbuild --lazarusdir=/usr/share/lazarus #g' {} \;
}

src_compile(){
	./build.sh beta || die
}

src_install(){
	diropts -m0755
	dodir /usr/share

	install/linux/install.sh --portable-prefix=build

	newicon pixmaps/mainicon/colored/v4_3.png ${ABBREV}.png

	rsync -a "${S}/build/" "${D}/usr/share/" || die "Unable to copy files"

	dosym ../share/${ABBREV}/${ABBREV} /usr/bin/${ABBREV}

	make_desktop_entry ${ABBREV} "Double Commander" "${ABBREV}" "Utility;" || die "Failed making desktop entry!"
}
