# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/tora/tora-3.0.0_pre20140918.ebuild,v 1.5 2014/09/18 Exp $

EAPI=6

inherit cmake-utils eutils

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/tora-tool/tora"
	inherit git-2
	KEYWORDS=""
else
	SRC_URI="https://github.com/tora-tool/tora/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	#SRC_URI="${PN}-master.tgz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="TOra - Toolkit For Oracle"
HOMEPAGE="https://github.com/tora-tool/tora/wiki"
IUSE="debug mysql pch postgres +qt5"

SLOT="0"
LICENSE="GPL-2"

RDEPEND="
	dev-libs/ferrisloki
	x11-libs/qscintilla[qt5?]
	qt5? (
		dev-qt/qtgui:5
		dev-qt/qtsql:5[mysql?,postgres?]
		dev-qt/qtxmlpatterns:5
		dev-qt/linguist:5
		dev-qt/qtnetwork:5
		dev-qt/qtsql:5
		dev-qt/qtxml:5 
	)
	!qt5? ( dev-qt/qtgui:4 dev-qt/qtsql:4[mysql?,postgres?] dev-qt/qtxmlpatterns:4 )
	>=dev-db/oracle-instantclient-basic-11
	postgres? ( dev-db/postgresql )
	dev-qt/linguist-tools
"

DEPEND="
	virtual/pkgconfig
	${RDEPEND}
"

PATCHES="${FILESDIR}/*.patch"

pkg_setup() {
	if [ -z "$ORACLE_HOME" ] ; then
		eerror "ORACLE_HOME variable is not set."
		eerror
		eerror "You must install Oracle >= 8i client for Linux in"
		eerror "order to compile TOra with Oracle support."
		eerror
		eerror "You can download the Oracle software from"
		eerror "http://otn.oracle.com/software/content.html"
		die
	fi
}

src_prepare() {
	# Clean 3rd-party dependencies to ensure usage right ones:
	#rm -rf extlibs/loki* || die	# for dev-libs/ferrisloki see bug #383109
	#
	sed -i \
		-e "/COPYING/ d" \
		CMakeLists.txt || die "Removal of COPYING file failed"
	# bug 547520
	grep -rlZ '$$ORIGIN' . | xargs -0 sed -i 's|:$$ORIGIN[^:"]*||' || \
		die 'Removal of $$ORIGIN failed'
	#
	default
}

src_configure() {
	local mycmakeargs=()
	mycmakeargs=(-DENABLE_ORACLE=ON)
	mycmakeargs+=(-DTARGET_NAME=ALL)
	# IMB DB2 support is very initial and for 2016-03-13 not planned to be complete
	mycmakeargs+=(-DENABLE_DB2=OFF)
	mycmakeargs+=(
		-DWANT_RPM=OFF
		-DWANT_BUNDLE=OFF
		-DWANT_BUNDLE_STANDALONE=OFF
		-DUSE_PCH="$(usex pch)"
		-DWANT_INTERNAL_QSCINTILLA=OFF
		-DWANT_INTERNAL_LOKI=OFF
		-DLOKI_LIBRARY="$(pkg-config --variable=libdir ferrisloki)/libferrisloki.so"
		-DLOKI_INCLUDE_DIR="$(pkg-config --variable=includedir ferrisloki)/FerrisLoki"
		-DENABLE_QT5_BUILD="$(usex qt5)"
		-DENABLE_PGSQL_="$(usex postgres)"
		-DWANT_DEBUG_="$(usex debug)"
		# path variables
		-DTORA_DOC_DIR=share/doc/${PF}
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	#
	doicon src/icons/${PN}.xpm || die
	domenu src/${PN}.desktop || die
}
