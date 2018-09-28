# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils qmake-utils

DESCRIPTION="Powerful yet simple to use screenshot software"
HOMEPAGE="https://github.com/lupoDharkael/flameshot"
SRC_URI="https://github.com/lupoDharkael/flameshot/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtsvg:5
"

src_configure() {
	eqmake5 CONFIG+=packaging
}

src_install() {
	emake install INSTALL_ROOT="${D}"
}
