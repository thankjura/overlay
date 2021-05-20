# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit cmake-utils git-r3 xdg-utils wrapper
CMAKE_BUILD_TYPE="Release"

DESCRIPTION="A joystick testing and configuration tool for Linux"
HOMEPAGE="https://gitlab.com/jstest-gtk/jstest-gtk.git"

LICENSE="GPLv3"
SLOT="0"

EGIT_REPO_URI="https://gitlab.com/jstest-gtk/jstest-gtk.git"
KEYWORDS="~amd64"

RDEPEND="dev-libs/libsigc++
	dev-cpp/gtkmm"
DEPEND="${RDEPEND}
	dev-util/cmake"

src_prepare() {
	cp "data/generic.png" "data/${PN}.png"
	default
}

src_configure() {
	cmake-utils_src_configure
}

src_install() {
	exeinto /usr/share/${PN}
	doexe "${CMAKE_BUILD_DIR}"/${PN}
	insinto /usr/share/${PN}
	doins -r "${S}"/data

	doicon ${S}/data/generic.png

	make_wrapper ${PN} /usr/share/${PN}/${PN} /usr/share/${PN}
	make_desktop_entry ${PN} "Joystick" ${PN} "Utility" "Path=/usr/share/${PN}\nStartupWMClass=${PN}"
}
