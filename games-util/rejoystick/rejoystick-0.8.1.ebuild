# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Program which translates gamepad/joystick input into key strokes/mouse actions in X"
HOMEPAGE="http://rejoystick.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-libs/gtk+:2
	x11-libs/libXtst
	media-libs/libsdl[joystick]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
src_configure() {
	eautoconf
	sed -i 's/\.\ version\.mk/\. \.\/version\.mk/g' ./configure
	econf --disable-dependency-tracking
}
src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
}
