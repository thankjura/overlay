# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit java-pkg-2

DESCRIPTION="Aqua Data Studio is productivity software for Database Developers"
HOMEPAGE="http://www.aquafold.com/aquadatastudio.html"
SRC_URI="Aqua_Data_Studio_${PV}.zip"

RESTRICT="fetch"

LICENSE="ADS"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

pkg_nofetch() {
	eerror "Please go to"
	eerror "	${HOMEPAGE}"
	eerror "and download"
	eerror "	LINUX Generic - No JVM"
	eerror "		${SRC_URI}"
	eerror "and move it to ${DISTDIR}"
}

src_install() {
	dodir /opt/${PN}	
	cp -r * "${D}"/opt/${PN}/ || die "Install failed"

	newbin "${FILESDIR}"/${PN} ${PN}

	newicon datastudio-48x48.png ${PN}.png
	make_desktop_entry ${PN} "Aqua Data Studio" ${PN}
}
