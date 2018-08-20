# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 gnome2-utils git-r3

DESCRIPTION="User-mode driver and GTK3 based GUI for Steam Controller"
HOMEPAGE="https://github.com/kozec/sc-controller/"

EGIT_REPO_URI="https://github.com/kozec/sc-controller.git"
#EGIT_COMMIT="5adab4fca31e448a003ca1e48ca3beec272f5f9b"

LICENSE="GPL2"
SLOT="0"
KEYWORDS=""

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
