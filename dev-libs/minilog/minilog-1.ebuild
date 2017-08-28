# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Minilog for Regard3D"
HOMEPAGE="https://github.com/rhiestan/Regard3D"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${FILESDIR}/minilog.tar.bz2
}

S=${WORKDIR}/minilog
