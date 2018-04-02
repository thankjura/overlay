# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MIN_VERSION="3.0"
PYTHON_COMPAT=( python{2_6,2_7,3_3,3_4,3_5,3_6} )

inherit cmake-utils gnome2-utils eutils python-single-r1

COMMIT="ad3727e1d5391899c783c94ffc2d537083f56309"

DESCRIPTION="ScreenCloud is an easy to use screenshot sharing tool"
HOMEPAGE="http://screencloud.net"
SRC_URI="https://github.com/olav-st/screencloud/archive/${COMMIT}.zip -> ${P}.zip"

LICENSE="GPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	${PYTHON_DEPS}
	dev-qt/qtsvg:5
	dev-qt/qtx11extras:5
	dev-qt/qtmultimedia:5
	dev-libs/quazip
	dev-python/PythonQt[${PYTHON_USEDEP}]
	dev-qt/qtconcurrent:5
	dev-python/pycrypto[${PYTHON_USEDEP}]
"

src_prepare() {
	eapply $FILESDIR/fix-qt.patch || die
	python_setup
	export PYTHON_INCLUDE_DIRS="$(python_get_includedir)" \
		PYTHON_INCLUDE_PATH="$(python_get_library_path)"\
		PYTHON_CFLAGS="$(python_get_CFLAGS)"\
	    PYTHON_LIBS="$(python_get_LIBS)"
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCONSUMER_KEY_SCREENCLOUD=${CONSUMER_KEY_SCREENCLOUD}
		-DCONSUMER_SECRET_SCREENCLOUD=${CONSUMER_SECRET_SCREENCLOUD}
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	ewarn
	ewarn "If you have login to screencloud.net"
	ewarn "visit https://screencloud.net/oauth/register"
	ewarn "and set enviroment: "
	ewarn "CONSUMER_KEY_SCREENCLOUD and CONSUMER_SECRET_SCREENCLOUD"
	ewarn
}
