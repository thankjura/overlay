# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils git-r3 flag-o-matic

DESCRIPTION="Open Multi-View Stereo reconstruction library"
HOMEPAGE="http://cdcseacave.github.io/openMVS"
EGIT_REPO_URI="https://github.com/cdcseacave/openMVS.git"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"

IUSE="-doc"

RDEPEND="
	>=sci-libs/ceres-solver-1.11
	media-libs/opencv
	dev-cpp/eigen:3
	sci-mathematics/cgal
	"

DEPEND="${RDEPEND}"

src_prepare() {
	cd ${WORKDIR}
	git clone https://github.com/cdcseacave/VCG.git vcglib
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		-DCMAKE_BUILD_TYPE=RELEASE
		-DVCG_DIR=${WORKDIR}/vcglib
		-DOpenMVS_USE_CUDA=OFF
		"
	cmake-utils_src_configure
}
src_install() {
	unset LDFLAGS
	cmake-utils_src_install
}
