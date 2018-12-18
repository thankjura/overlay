# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Shell-centric MongoDB management tool"
HOMEPAGE="https://robomongo.org/"
PKG_NAME=${P}-linux-x86_64-3e50a65
SRC_URI="https://download.robomongo.org/${PV}/linux/${PKG_NAME}.tar.gz"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-libs/libpcre
"
RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}/${PKG_NAME}

src_install() {
	newbin bin/robo3t ${PN}
	newicon logo-256x256.png ${PN}.png
	make_desktop_entry ${PN} Robo3T ${PN} Development
}
