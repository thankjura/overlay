# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils meson

DESCRIPTION="A GTK patchbay for pipewire"
HOMEPAGE="https://gitlab.freedesktop.org/ryuukyu/helvum"
SRC_URI="https://gitlab.freedesktop.org/pipewire/helvum/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="network-sandbox"

DEPEND=">=media-video/pipewire-0.3
		>=gui-libs/gtk-4.4.0"
RDEPEND="${DEPEND}"
BDEPEND=">=sys-devel/clang-3.7
		dev-util/meson
		virtual/rust"

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
