# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit cmake-utils eutils git-r3

DESCRIPTION="Stepmania 5 sm-ssc branch"
HOMEPAGE="https://github.com/stepmania/stepmania"
SRC_URI=""

EGIT_BRANCH="5_1-new"
EGIT_REPO_URI="https://github.com/stepmania/stepmania.git"
EGIT_SUBMODULES=(
	"extern/cppformat"
	"extern/googletest"
	"extern/tomcrypt"
	"extern/tommath"
	"extern/libpng"
	"extern/ffmpeg-git"
	"extern/ffmpeg-linux-2.1.3"
)

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +jpeg +mp3 +vorbis sse2"

DEPEND="x11-libs/gtk+:2
	media-libs/alsa-lib
	mp3? ( media-libs/libmad )
	vorbis? ( media-libs/libvorbis )
	media-libs/libpng
	jpeg? ( virtual/jpeg )
	virtual/glu
	x11-libs/libXrandr
	media-libs/glew
	virtual/opengl
	dev-libs/libpcre
	dev-libs/jsoncpp
"

remove_bundled_lib() {
	local blib_prefix
	blib_prefix="${S}/extern"
	einfo "Removing bundled library $1 ..."
	rm -rf "${blib_prefix}/$1" || die "Failed removing bundled library $1"
}

src_prepare() {
	sed -i "s:../extern/pcre/pcre.h:pcre.h:" src/RageUtil.cpp
	# Remove bundled libs, to know if they become forked as lua already is.
	remove_bundled_lib "libjpeg"
	#remove_bundled_lib "libpng"
	#remove_bundled_lib "libtomcrypt"
	#remove_bundled_lib "libtommath"
	remove_bundled_lib "mad-0.15.1b"
	remove_bundled_lib "pcre"
	remove_bundled_lib "vorbis"
	remove_bundled_lib "zlib"

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX_OPT}
		-DWITH_SYSTEM_FFMPEG=ON
		-DWITH_SYSTEM_ZLIB=ON
		-DWITH_FFMPEG=ON
		-DWITH_UNIT_TESTS=OFF
		-DWITH_SYSTEM_PCRE=ON
		-DWITH_SSE2=$(usex sse2)
		-DWITH_JPEG=$(usex jpeg)
		-DWITH_SYSTEM_JPEG=ON
		-DWITH_SYSTEM_MAD=ON
		-DWITH_MP3=$(usex mp3)
		-DWITH_OGG=$(usex vorbis)
		-DWITH_MINIMAID=OFF
		-DWITH_X11=ON
		-DWITH_FULL_RELEASE=ON
		-DWITH_PULSEAUDIO=ON
		-DWITH_GLES2=ON
		-DWITH_XINERAMA=ON
		-DWITH_SDL=ON
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_TOMMATH=ON
		-DWITH_SYSTEM_MAD=ON
		-DWITH_XRANDR=ON

	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	make_wrapper ${PN} ${GAMES_PREFIX_OPT}/${PN}-5.1/${PN}
	newicon "Themes/default/Graphics/Common window icon.png" ${PN}.png
	make_desktop_entry ${PN} Stepmania ${PN}
}
