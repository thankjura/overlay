# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.gnome.org/jadahl/libdecor.git"
else
	SRC_URI="https://gitlab.freedesktop.org/libdecor/libdecor/-/archive/${PV}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="A client-side decorations library for Wayland clients"
HOMEPAGE="https://gitlab.freedesktop.org/libdecor/libdecor"
LICENSE="MIT"
SLOT="0"
IUSE="+dbus examples"

DEPEND="
	>=dev-libs/wayland-1.18
	>=dev-libs/wayland-protocols-1.15
	x11-libs/pango
	dbus? ( sys-apps/dbus )
	examples? (
		virtual/opengl
		dev-libs/wayland
		media-libs/mesa[egl(+)]
		x11-libs/libxkbcommon
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-build/meson-0.47
	examples? ( dev-libs/wayland-protocols )
"

src_configure() {
	local emesonargs=(
		$(meson_feature dbus)
		$(meson_use examples demo)
		#-Dinstall_demo=false
	)

	meson_src_configure
}
