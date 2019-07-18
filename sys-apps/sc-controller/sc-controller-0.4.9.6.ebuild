# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 gnome2-utils

COMMIT="49714127707499fd1569534c4f0f4dba72b25a75"

DESCRIPTION="User-mode driver and GTK3 based GUI for Steam Controller"
HOMEPAGE="https://github.com/kozec/sc-controller/"
#SRC_URI="https://github.com/kozec/sc-controller/archive/v${PV}.tar.gz"
SRC_URI="https://github.com/kozec/sc-controller/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+evdev"

RDEPEND="${PYTHON_DEPS}
	evdev? (
		dev-python/python-evdev[${PYTHON_USEDEP}]
		dev-python/pyinotify[${PYTHON_USEDEP}]
	)
	dev-python/pycairo
	dev-python/pylibacl
	>=x11-libs/gtk+-3.10"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}-${COMMIT}

src_install() {
	distutils-r1_src_install
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
