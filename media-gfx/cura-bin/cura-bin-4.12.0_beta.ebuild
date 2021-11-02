# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

MY_PV=${PV/_beta/-BETA}

DESCRIPTION="A 3D model slicing application for 3D printing"
HOMEPAGE="https://github.com/Ultimaker/Cura"
SRC_URI="https://github.com/Ultimaker/Cura/releases/download/4.12-beta/Ultimaker_Cura-${MY_PV}.AppImage -> ${P}.appimage"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	!media-gfx/cura
"
RDEPEND="${DEPEND}"

S=${DISTDIR}

src_install() {
	newbin ${P}.appimage cura
	newicon ${FILESDIR}/cura-128.png cura.png
	make_desktop_entry cura Cura
}
