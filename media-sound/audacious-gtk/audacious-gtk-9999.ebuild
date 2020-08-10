# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg autotools git-r3

EGIT_REPO_URI="https://github.com/audacious-media-player/audacious.git"
EGIT_BRANCH="master-gtk3"

KEYWORDS="amd64 x86"

DESCRIPTION="Lightweight and versatile audio player"
HOMEPAGE="https://audacious-media-player.org/"
SRC_URI+=" mirror://gentoo/gentoo_ice-xmms-0.2.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
IUSE="nls"

BDEPEND="
	virtual/pkgconfig
	nls? ( dev-util/intltool )
"
DEPEND="
	>=dev-libs/dbus-glib-0.60
	>=dev-libs/glib-2.28
	>=x11-libs/gtk+-3.4:3
	>=x11-libs/cairo-1.2.6
	>=x11-libs/pango-1.8.0
	virtual/freedesktop-icon-theme
"
RDEPEND="${DEPEND}"
PDEPEND="~media-plugins/audacious-plugins-gtk-${PV}"

src_unpack() {
	default
	git-r3_src_unpack
}

src_prepare() {
	default
	if ! use nls; then
		sed -e "/SUBDIRS/s/ po//" -i Makefile || die # bug #512698
	fi
	eautoreconf
}

src_configure() {
	# D-Bus is a mandatory dependency, remote control,
	# session management and some plugins depend on this.
	# Building without D-Bus is *unsupported* and a USE-flag
	# will not be added due to the bug reports that will result.
	# Bugs #197894, #199069, #207330, #208606
	local myeconfargs=(
		--disable-valgrind
		--enable-gtk
		--enable-dbus
		--disable-qt
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# Gentoo_ice skin installation; bug #109772
	insinto /usr/share/audacious/Skins/gentoo_ice
	doins -r "${WORKDIR}"/gentoo_ice/.
	docinto gentoo_ice
	dodoc "${WORKDIR}"/README
}
