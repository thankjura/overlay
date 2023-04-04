# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Free digital painting application. Digital Painting, Creative Freedom!"
HOMEPAGE="https://krita.org/"
SRC_URI="http://download.kde.org/stable/krita/${PV/b/}/krita-${PV}-x86_64.appimage"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	!media-gfx/krita
"
RDEPEND="${DEPEND}"

S=${DISTDIR}

src_install() {
	newbin krita-${PV}-x86_64.appimage ${PN}
	newicon ${FILESDIR}/krita.png ${PN}.png
	make_desktop_entry ${PN} Krita
}
