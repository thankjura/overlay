# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit eutils gnome2-utils distutils-r1

DESCRIPTION="A state of the art, easy to use SIP client"
HOMEPAGE="http://iCanBlink.com"
SRC_URI="https://github.com/AGProjects/blink-qt/archive/release-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

KEYWORDS="~amd64 ~x86"

CDEPEND="net-libs/libvncserver"
RDEPEND="${CDEPEND}
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/PyQt5[webkit,${PYTHON_USEDEP}]
	>=dev-python/python-application-2.0[${PYTHON_USEDEP}]
	dev-python/python-cjson[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/python-eventlib[${PYTHON_USEDEP}]
	>=dev-python/python-sipsimple-3.0[${PYTHON_USEDEP}]
	dev-python/twisted-core[${PYTHON_USEDEP}]
	dev-python/zope-interface[${PYTHON_USEDEP}]
	dev-python/google-api-python-client[${PYTHON_USEDEP}]
"
DEPEND="${CDEPEND}
	dev-python/cython[${PYTHON_USEDEP}]"

	PATCHES=( "${FILESDIR}/blink-1.4.1-data-path.patch" )

S=${WORKDIR}/${PN}-qt-release-${PV}

src_install() {
	distutils-r1_src_install

	newicon -s 48 resources/icons/blink48.png blink.png
	newicon -s 64 resources/icons/blink64.png blink.png
	doicon -s 512 resources/icons/blink.png

	make_desktop_entry ${PN} Blink
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
