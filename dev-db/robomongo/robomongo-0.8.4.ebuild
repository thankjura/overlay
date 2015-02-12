# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils

DESCRIPTION="Robomongo — is a shell-centric crossplatform MongoDB management
tool."

HOMEPAGE="http://www.robomongo.org/"
SRC_URI="https://github.com/paralect/robomongo/archive/v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">dev-qt/qtcore-5
		>dev-qt/qtgui-5
		>dev-qt/qtdbus-5
		>dev-qt/qtprintsupport-5
		dev-db/mongodb
		dev-libs/qjson
		x11-libs/qscintilla"

RDEPEND="${DEPEND}"

S=${WORKDIR}"/"${P}

#src_prepare() {
#	epatch "${FILESDIR}"/fix_compile.patch
#	epatch "${FILESDIR}"/fix_pch.patch
#	epatch "${FILESDIR}"/fix-qt54.patch
#	distutils_src_prepare
#}

scr_configure() {
        local mycmakeargs=(
			-DOS_ARC=64
        )
        cmake-utils_src_configure
}
