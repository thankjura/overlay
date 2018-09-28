# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MIN_VERSION="3.0"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit cmake-utils python-single-r1 xdg-utils

DESCRIPTION="ScreenCloud is an easy to use screenshot sharing tool"
HOMEPAGE="http://screencloud.net"
SRC_URI="https://github.com/olav-st/screencloud/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	${PYTHON_DEPS}
	dev-qt/qtsvg:5
	dev-qt/qtx11extras:5
	dev-qt/qtmultimedia:5[widgets]
	dev-libs/quazip
	dev-python/PythonQt[${PYTHON_USEDEP}]
	dev-qt/qtconcurrent:5
	dev-python/pycrypto[${PYTHON_USEDEP}]
"

src_configure() {
	local mycmakeargs=(
		-DQT_USE_QT5=ON
		-DPYTHON_USE_PYTHON3="$(usex python_single_target_python2_7 OFF ON)"
		-DCMAKE_BUILD_TYPE=Release
		-DCOLOR_OUTPUT:BOOL='ON'
		-Wno-dev
	)
	cmake-utils_src_configure
}

pkg_postinst(){
	xdg_desktop_database_update
}

pkg_postrm(){
	xdg_desktop_database_update
}
