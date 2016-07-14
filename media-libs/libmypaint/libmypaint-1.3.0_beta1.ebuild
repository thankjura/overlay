# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

MY_PV=${PV/_beta1}

SRC_URI="https://github.com/mypaint/libmypaint/archive/v${MY_PV}-beta.1.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"

DESCRIPTION="This is the brush library used by MyPaint. A number of other painting programs use it too."
HOMEPAGE="https://github.com/mypaint/libmypaint"

LICENSE="ISC"
SLOT="0"
IUSE=""

DEPEND="
	virtual/pkgconfig
"

S=${WORKDIR}/${PN}-${MY_PV}-beta.1

src_prepare() {
	default
	./autogen.sh || die
}
