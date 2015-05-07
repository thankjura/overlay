# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/tilda/tilda-1.1.8.ebuild $

EAPI=4

inherit eutils gnome2 autotools git-2

DESCRIPTION="A drop down terminal, similar to the consoles found in first person shooters"
HOMEPAGE="https://github.com/lanoxx/tilda"
EGIT_BRANCH="vteport"
EGIT_COMMIT="d285dee4ecc9fbd6fd4d50db5811600b4593e8dd"
EGIT_REPO_URI="git://github.com/pik/tilda.git"
#SRC_URI="https://github.com/lanoxx/tilda/archive/${P}.tar.gz"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/vte:2.91
	>=dev-libs/glib-2.30:2
	x11-libs/gtk+:3
	dev-libs/confuse"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

#S=${WORKDIR}"/"${PN}-${COMMIT}

src_configure() {
	eautoreconf || die
	econf || die
}
