# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="7"
IUSE=""

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
#QA_PREBUILT="*"
#QA_FLAGS_IGNORED=".*"
FAUST_LIB_COMMIT="8d7cd8ffaad4ad5fb996b965f53d8ec01229a5e9"

DESCRIPTION="functional programming language for realtime audio plugins"
HOMEPAGE="http://faudiostream.sourceforge.net"
SRC_URI="
		https://github.com/grame-cncm/faust/archive/refs/tags/${PV}.tar.gz
		https://github.com/grame-cncm/faustlibraries/archive/${FAUST_LIB_COMMIT}.zip -> faust-libraries-${PV}.zip
"

RDEPEND="
	sys-devel/bison
	sys-devel/flex
"
DEPEND="sys-apps/sed"

src_prepare() {
	eapply_user
	rmdir libraries
	mv ../faustlibraries-${FAUST_LIB_COMMIT} libraries
	sed -i "s/\/usr\/local/\/usr/g" Makefile || die
}

src_compile() {
	emake PREFIX=/usr || die "parallel make failed"
}

src_install() {
	#dodir ${D}/usr/lib/faust
	make install DESTDIR=${D}
	#dodoc README.md
}
