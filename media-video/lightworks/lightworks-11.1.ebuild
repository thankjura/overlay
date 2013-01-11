# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils unpacker

DESCRIPTION="Lightworks NLE - Designed by editors, for editors"
HOMEPAGE="http://www.lwks.com/"

SRC_URI="lwks-${PV}.D-amd64.deb"

LICENSE="lwks"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="x11-libs/qt-core"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	dobin "usr/bin/lightworks"

	insinto "/usr/lib/"
	doins -r usr/lib/lightworks

	dodoc usr/share/doc/lightworks/changelog.gz
	dodoc usr/share/doc/lightworks/copyright

	domenu usr/share/applications/lightworks.desktop

	insinto /usr/share/
	doins -r usr/share/fonts/
	doins -r usr/share/lightworks/
}
