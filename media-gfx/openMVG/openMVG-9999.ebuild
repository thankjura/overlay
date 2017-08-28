# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils eutils git-r3 flag-o-matic

DESCRIPTION="Open Multiple View Geometry library"
HOMEPAGE="http://imagine.enpc.fr/~moulonp/openMVG/"
EGIT_REPO_URI="https://github.com/openMVG/openMVG.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="openmp opencv +neato -doc"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:0/16
	opencv? ( media-libs/opencv:0/3.2[contrib] )
	dev-cpp/eigen:3
	sci-libs/cxsparse
	sci-libs/lemon[coin]
	media-libs/tiff
	sys-libs/zlib
	neato? ( media-gfx/graphviz )
	sci-libs/flann
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"
PREFIX="/usr"

src_prepare() {
	#cleanup third_party dir
	rm -r ${S}/src/dependencies/osi_clp
	eapply ${FILESDIR}/libopenMVG_sfm_link_error.patch
	eapply ${FILESDIR}/document.h.patch
	eapply_user
}

src_configure() {
	export OPENMVG_USE_AVX2=1
	local mycmakeargs=(
		-DOpenMVG_USE_OPENMP="$(usex openmp)"
		-DOpenMVG_BUILD_DOC="$(usex doc)"
		-DOpenMVG_USE_OPENCV="$(usex opencv)"
		-DOpenMVG_USE_OCVSIFT="$(usex openmp)"
		-DOpenMVG_BUILD_TESTS=OFF
		-DOpenMVG_BUILD_EXAMPLES=OFF
		-DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF
		-DOpenMVG_BUILD_TESTS=OFF
		-DOpenMVG_BUILD_SHARED=OFF
		-DOPENMVG_USE_AVX2=ON
		-DFLANN_INCLUDE_DIR_HINTS="/usr/include/flann"
		-DEIGEN_INCLUDE_DIR_HINTS="/usr/include/eigen3"
		-DCOINUTILS_INCLUDE_DIR_HINTS="/usr/include/coin" 
		-DCLP_INCLUDE_DIR_HINTS="/usr/include/coin" 
		-DCLPSOLVER_LIBRARY="/usr/lib/libOsiClp.so" 
		-DOSI_INCLUDE_DIR_HINTS="/usr/include/coin" 
		-DLEMON_INCLUDE_DIR_HINTS="/usr/include" 
		-DLEMON_LIBRARY="/usr/lib/libemon.so"
	)
	cmake-utils_src_configure
	cp ${BUILD_DIR}/software/SfMWebGLViewer/config.h ${CMAKE_USE_DIR}/software/SfMWebGLViewer/config.h || die
}
src_install() {
	unset LDFLAGS
	cmake-utils_src_install
	mkdir -p ${D}usr/include/openMVG/software/SfM
	mkdir -p ${D}usr/include/openMVG/software/SfMViewer
	cp -a ${CMAKE_USE_DIR}/software/SfM/{*.h,*.hpp} ${D}usr/include/openMVG/software/SfM || die
	cp -a ${CMAKE_USE_DIR}/software/SfMViewer/*.h ${D}usr/include/openMVG/software/SfMViewer || die
}
