# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit unpacker

DESCRIPTION="Meet the best cryptocurrency mining pool & GUI miner"
HOMEPAGE="https://minergate.com/"
SRC_URI="https://minergate.com/download/deb-cli -> ${P}.deb"

LICENSE="custom"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	cp -R * ${D}
}
