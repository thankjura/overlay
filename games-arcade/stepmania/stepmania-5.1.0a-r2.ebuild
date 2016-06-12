# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit games cmake-utils eutils

TOMMATH_VER="1.0"
TOMCRYPT_VER="1.16"
CPPFORMAT_VER="2.0.0"
GTEST_VER="ff07a5de0e81580547f1685e101194ed1a4fcd56"

DESCRIPTION="Stepmania 5 sm-ssc branch"
HOMEPAGE="https://github.com/stepmania/stepmania"
SRC_URI="https://github.com/stepmania/stepmania/archive/v${PV}2.tar.gz
		 https://github.com/libtom/libtomcrypt/archive/${TOMCRYPT_VER}.tar.gz -> libtomcrypt-${TOMCRYPT_VER}.tar.gz 
		 https://github.com/libtom/libtommath/archive/v${TOMMATH_VER}.tar.gz -> libtommath-${TOMMATH_VER}.tar.gz
		 https://github.com/cppformat/cppformat/archive/${CPPFORMAT_VER}.tar.gz -> cppformat-${CPPFORMAT_VER}.tar.gz
		 https://github.com/google/googletest/archive/${GTEST_VER}.zip -> googletest-${GTEST_VER}.zip"

# EGIT_REPO_URI="git://github.com/stepmania/stepmania.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug X gtk +jpeg +mad +vorbis +network +ffmpeg sse2"

S="${WORKDIR}/stepmania-5.1.0a2"

DEPEND="gtk? ( x11-libs/gtk+:2 )
	media-libs/alsa-lib
	mad? ( media-libs/libmad )
	vorbis? ( media-libs/libvorbis )
	media-libs/libpng
	jpeg? ( virtual/jpeg )
	ffmpeg? ( >=virtual/ffmpeg-0.5 )
	virtual/glu
	x11-libs/libXrandr
	media-libs/glew
	virtual/opengl
	dev-libs/libpcre
	dev-libs/jsoncpp"

remove_dev_theme() {
	local theme_dir
	theme_dir="${S}/Themes"
	einfo "Removing dev theme $1 ..."
	rm -rf "${theme_dir}/$1" || die "Failed removing dev theme $1"
}

src_prepare() {

	# Remove dev themes
	remove_dev_theme "default-dev-midi"
	remove_dev_theme "HelloWorld"
	remove_dev_theme "MouseTest"
	remove_dev_theme "rsr"

	# Apply various patches
	#	00 - 09: Filepath changes
	#	10 - 19: De-bundle patches
	#	20 - 29: Other fixes
	#	30 - 39; Non-important gameplay patches
	EPATCH_SOURCE="${FILESDIR}" EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="no" epatch || die "Patching failed!"
	rmdir ${S}/extern/tommath
	rmdir ${S}/extern/tomcrypt
	rmdir ${S}/extern/cppformat
	rmdir ${S}/extern/googletest
	#rmdir ${S}/extern/googletest
	mv ${WORKDIR}/libtomcrypt-${TOMCRYPT_VER} ${S}/extern/tomcrypt
	mv ${WORKDIR}/libtommath-${TOMMATH_VER} ${S}/extern/tommath
	mv ${WORKDIR}/cppformat-${CPPFORMAT_VER} ${S}/extern/cppformat
	mv ${WORKDIR}/googletest-${GTEST_VER} ${S}/extern/googletest
}

src_configure() {
	mycmakeargs="
	-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX_OPT}
	-DWITH_SYSTEM_FFMPEG:BOOL='1'
	-DWITH_SYSTEM_PCRE:BOOL='1'
	-DBUILD_UNIT_TESTS=OFF
	"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	games_make_wrapper ${PN} ${GAMES_PREFIX_OPT}/${PN}-5.0/${PN}
	newicon "Themes/default/Graphics/Common window icon.png" ${PN}.png
	make_desktop_entry ${PN} Stepmania ${PN}
	prepgamesdirs
}
