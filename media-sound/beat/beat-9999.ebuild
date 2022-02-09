# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..10} )

inherit git-r3 gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Music player for Gnome"
HOMEPAGE="https://github.com/thankjura/beat-audio-player"

EGIT_REPO_URI="https://github.com/thankjura/beat-audio-player.git"

LICENSE="GPL-3"
SLOT="0"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

KEYWORDS="amd64 ~arm64 x86"

DEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.50:2
	>=dev-libs/gobject-introspection-1.54:=
	>=x11-libs/gtk+-3.24.7:3[introspection]
	$(python_gen_cond_dep '
		>=dev-python/pygobject-3.29.1:3[${PYTHON_USEDEP}]
	')
"

pkg_setup() {
	python_setup
}

src_install() {
	meson_src_install
	python_fix_shebang -f "${D}"/usr/bin/beat || die
	python_optimize
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
