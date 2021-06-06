# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Set of tools for FFB testing and debugging on GNU/Linux"
HOMEPAGE="https://github.com/berarma/ffbtools"
EGIT_REPO_URI="https://github.com/berarma/ffbtools.git"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	dobin ${FILESDIR}/ffbwrap
	dobin build/ffbplay
	dobin build/rawcmd
	dolib.so build/libffbwrapper-x86_64.so
}
