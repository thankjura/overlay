# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit cmake-utils gnome2 vala

CMAKE_MIN_VERSION="2.6"
VALA_MIN_API_VERSION="0.26"
COMMIT="abaafccc099d2ee635563eb06880e6e7e142bd1b"
DESCRIPTION="FeedReader is a modern desktop application designed to complement existing web-based RSS accounts"
HOMEPAGE="http://jangernert.github.io/FeedReader/"
#SRC_URI="https://github.com/jangernert/FeedReader/archive/v${PV}.tar.gz"
SRC_URI="https://github.com/jangernert/FeedReader/archive/${COMMIT}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=x11-libs/gtk+-3.12:3
	$(vala_depend)
	dev-libs/json-glib
	dev-libs/libgee:0.8
	net-libs/libsoup:2.4
	dev-db/sqlite:3
	app-crypt/libsecret[vala]
	x11-libs/libnotify
	dev-libs/libxml2
	net-libs/rest:0.7
	net-libs/webkit-gtk:4
	dev-libs/gobject-introspection"

DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig"

#S="${WORKDIR}/FeedReader-${PV}"
S="${WORKDIR}/FeedReader-${COMMIT}"
CMAKE_IN_SOURCE_BUILD=true

src_configure() {
	local mycmakeargs=(
		-DWITH_LIBUNITY=OFF
		-DVALA_EXECUTABLE="${VALAC}"
		-DCMAKE_INSTALL_PREFIX="${PREFIX}"
		-DGSETTINGS_LOCALINSTALL=OFF
	)
	cmake-utils_src_configure
}
