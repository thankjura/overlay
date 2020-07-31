# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils cmake-utils

DESCRIPTION="DeaDBeeF plasma5 tray icon plugin"
HOMEPAGE="https://github.com/vovochka404/deadbeef-statusnotifier-plugin"
SRC_URI="https://github.com/vovochka404/deadbeef-statusnotifier-plugin/archive/v${PV}.tar.gz -> ${P}.tar.gz"

IUSE="gtk2 +gtk3"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"

RDEPEND="
	media-sound/deadbeef
	dev-libs/libdbusmenu:0
	gtk2? ( media-sound/deadbeef[gtk2] )
	gtk3? ( media-sound/deadbeef[gtk3] )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}/deadbeef-statusnotifier-plugin-${PV}"

PATCHES="${FILESDIR}/fix.patch"

src_configure() {
	local mycmakeargs=(
		-DUSE_GTK2="$(usex gtk2)"
		-DUSE_GTK3="$(usex gtk3)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	local plugins="$(find "${WORKDIR}" -name "*.so" -type f)"
	for plugin in ${plugins} ; do
		insinto "/usr/$(get_libdir)/deadbeef"
		doins "${plugin}"
	done
}
