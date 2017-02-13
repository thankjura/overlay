# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils toolchain-funcs git-r3 flag-o-matic

DESCRIPTION="A powerful cross-platform raw image processing program"
HOMEPAGE="http://www.rawtherapee.com/"
EGIT_REPO_URI="https://github.com/Beep6581/RawTherapee.git"
EGIT_BRANCH="dev"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bzip2 gtk2 openmp"

RDEPEND="bzip2? ( app-arch/bzip2 )
	gtk2? (
		>=x11-libs/gtk+-2.24.18:2
		>=dev-cpp/gtkmm-2.12:2.4
		>=dev-cpp/glibmm-2.16:2
		media-libs/libcanberra[gtk]
	)
	!gtk2? (
		>=x11-libs/gtk+-3.16:3
		>=dev-cpp/gtkmm-3.16:3.0
		>=dev-cpp/glibmm-2.44:2
		media-libs/libcanberra[gtk3]
	)
	media-libs/tiff:0
	media-libs/libpng:0
	media-libs/libiptcdata
	media-libs/lcms:2
	sci-libs/fftw:3.0
	sys-libs/zlib
	virtual/jpeg:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig"

pkg_setup() {
	if use gtk2 ; then
		EGIT_BRANCH="master"
	fi
}

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
	# build requires -std=c++11
	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! test-flag-CXX -std=c++11; then
			eerror "${P} requires C++11-capable C++ compiler. Your current compiler"
			eerror "does not seem to support -std=c++11 option. Please upgrade your compiler"
			eerror "to gcc-4.7 or an equivalent version supporting C++11."
			die "Currently active compiler does not support -std=c++11"
		fi
	fi
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use openmp OPTION_OMP)
		$(cmake-utils_use_with bzip2 BZIP)
		-DDOCDIR=/usr/share/doc/${PF}
		-DCREDITSDIR=/usr/share/${PN}
		-DLICENCEDIR=/usr/share/${PN}
		-DCACHE_NAME_SUFFIX=""
	)
	cmake-utils_src_configure
}
