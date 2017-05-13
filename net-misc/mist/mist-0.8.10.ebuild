# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit versionator

MY_PV=$(replace_all_version_separators '-')

DESCRIPTION="Mist dapp browser and Ethereum wallet"
HOMEPAGE="https://github.com/ethereum/mist"
SRC_URI="https://github.com/ethereum/mist/releases/download/v${PV}/Mist-linux64-${MY_PV}.zip -> ${P}.zip"


LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/libnotify
	net-libs/nodejs
	sys-libs/gpm
	sys-libs/readline
	gnome-base/gconf
"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	mkdir ${D}/opt
	mv linux-unpacked ${D}opt/mist || die
	dosym /opt/mist/mist /usr/bin/mist
	doicon ${FILESDIR}/${PN}.png
	make_desktop_entry ${PN} "Mist browser" ${PN}
}
