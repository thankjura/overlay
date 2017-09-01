# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit cmake-utils eutils git-r3

DESCRIPTION="Stepmania 5 sm-ssc branch"
HOMEPAGE="https://github.com/stepmania/stepmania"
SRC_URI=""

EGIT_REPO_URI="https://github.com/stepmania/stepmania.git"
EGIT_SUBMODULES=(
	"extern/cppformat"
	"extern/googletest"
	"extern/tomcrypt"
	"extern/tommath"
	"extern/libpng"
)

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +jpeg +mp3 +vorbis +ffmpeg sse2"

DEPEND="x11-libs/gtk+:2
	media-libs/alsa-lib
	mp3? ( media-libs/libmad )
	vorbis? ( media-libs/libvorbis )
	media-libs/libpng
	jpeg? ( virtual/jpeg )
	ffmpeg? ( >=virtual/ffmpeg-0.5 )
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
	remove_bundled_lib "ffmpeg"
	remove_bundled_lib "libjpeg"
	remove_bundled_lib "libpng"
	#remove_bundled_lib "libtomcrypt"
	#remove_bundled_lib "libtommath"
	remove_bundled_lib "mad-0.15.1b"
	remove_bundled_lib "pcre"
	remove_bundled_lib "vorbis"
	remove_bundled_lib "zlib"
	
	# Apply various patches
	#	00 - 09: Filepath changes
	#	10 - 19: De-bundle patches
	#	20 - 29: Other fixes
	#	30 - 39; Non-important gameplay patches
	EPATCH_SOURCE="${FILESDIR}" EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="no" epatch || die "Patching failed!"
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX_OPT}
		-DWITH_SYSTEM_FFMPEG=ON
		-DWITH_FFMPEG=$(usex ffmpeg)
		-DWITH_UNIT_TESTS=OFF
		-DWITH_SSE2=$(usex sse2)
		-DWITH_JPEG=$(usex jpeg)
		-DWITH_MP3=$(usex mp3)
		-DWITH_OGG=$(usex vorbis)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	make_wrapper ${PN} ${GAMES_PREFIX_OPT}/${PN}-5.1/${PN}
	newicon "Themes/default/Graphics/Common window icon.png" ${PN}.png
	make_desktop_entry ${PN} Stepmania ${PN}
}
