# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MIN_VERSION="3.0"
PYTHON_COMPAT=( python{2_6,2_7,3_3,3_4,3_5} )

inherit cmake-utils gnome2-utils eutils python-r1

DESCRIPTION="ScreenCloud is an easy to use screenshot sharing tool"
HOMEPAGE="http://screencloud.net"
SRC_URI="https://github.com/olav-st/screencloud/archive/v${PV}.tar.gz"

LICENSE="GPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtsvg:5
	dev-qt/qtx11extras:5
	dev-qt/qtmultimedia:5
	dev-libs/quazip
	dev-python/PythonQt
	dev-qt/qtconcurrent:5
"

src_prepare() {
	python_setup
	export PYTHON_INCLUDE_DIRS="$(python_get_includedir)" \
		PYTHON_INCLUDE_PATH="$(python_get_library_path)"\
		PYTHON_CFLAGS="$(python_get_CFLAGS)"\
	    PYTHON_LIBS="$(python_get_LIBS)"
	cmake-utils_src_prepare
}
