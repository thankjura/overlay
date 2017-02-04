# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Raw thumbnailer, based on ufraw-batch"
HOMEPAGE="ufraw.sourceforge"

LICENSE="GPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	media-gfx/ufraw
	!media-gfx/raw-thumbnailer
	!media-gfx/gnome-raw-thumbnailer
"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	insinto /usr/share/thumbnailers
	doins ${FILESDIR}/ufraw.thumbnailer
}
