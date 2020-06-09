# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome2-utils meson virtualx xdg

DESCRIPTION="GTK+ based distraction free Markdown editor"
HOMEPAGE="https://gitlab.gnome.org/somas/apostrophe"
SRC_URI="https://gitlab.gnome.org/somas/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/gtk+:3
	app-text/gspell
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}-v${PV}

src_test() {
	glib-compile-schemas "${BUILD_DIR}"/data
	GSETTINGS_SCHEMA_DIR="${BUILD_DIR}"/data virtx meson_src_test
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
