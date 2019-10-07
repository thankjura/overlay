# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic toolchain-funcs

DESCRIPTION="Collection of high-performance ray tracing kernels"
HOMEPAGE="https://github.com/embree/embree"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/embree/embree.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/embree/embree/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"

IUSE="clang ispc +tbb tutorial" # ${CPU_FLAGS[@]%:*}

REQUIRED_USE="clang? ( !tutorial )"

RDEPEND="
	>=media-libs/glfw-3.2.1
	virtual/opengl
	ispc? ( dev-lang/ispc )
	tbb? ( dev-cpp/tbb )
	tutorial? (
		>=media-libs/libpng-1.6.34:0=
		>=media-libs/openimageio-1.8.7
		virtual/jpeg:0
	)
"

DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	clang? ( sys-devel/clang )
"

DOCS=( CHANGELOG.md README.md readme.pdf )

CMAKE_BUILD_TYPE=Release

src_configure() {
	if use clang; then
		export CC=clang
		export CXX=clang++
		strip-flags
		filter-flags "-frecord-gcc-switches"
		filter-ldflags "-Wl,--as-needed"
		filter-ldflags "-Wl,-O1"
		filter-ldflags "-Wl,--defsym=__gentoo_check_ldflags__=0"
	fi

	local mycmakeargs=(
		-DBUILD_TESTING:BOOL=OFF
#		-DCMAKE_C_COMPILER=$(tc-getCC)
#		-DCMAKE_CXX_COMPILER=$(tc-getCXX)
		-DCMAKE_SKIP_INSTALL_RPATH:BOOL=ON
		-DEMBREE_FILTER_FUNCTION=ON				# default
		-DEMBREE_GEOMETRY_CURVE=ON				# default
		-DEMBREE_GEOMETRY_GRID=ON				# default
		-DEMBREE_GEOMETRY_INSTANCE=ON			# default
		-DEMBREE_GEOMETRY_POINT=ON				# default
		-DEMBREE_GEOMETRY_QUAD=ON				# default
		-DEMBREE_GEOMETRY_SUBDIVISION=ON		# default
		-DEMBREE_GEOMETRY_TRIANGLE=ON			# default
		-DEMBREE_GEOMETRY_USER=ON				# default
		-DEMBREE_ISPC_SUPPORT=$(usex ispc)
		-DEMBREE_RAY_PACKETS=ON					# default
		-DEMBREE_STATIC_LIB=OFF
		-DEMBREE_TASKING_SYSTEM:STRING=$(usex tbb "TBB" "INTERNAL")
		-DEMBREE_TUTORIALS=$(usex tutorial)
	)

	if use tutorial; then
		mycmakeargs+=(
			-DEMBREE_ISPC_ADDRESSING:STRING="64"
			-DEMBREE_TUTORIALS_LIBJPEG=ON
			-DEMBREE_TUTORIALS_LIBPNG=ON
			-DEMBREE_TUTORIALS_OPENIMAGEIO=ON
		)
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	doenvd "${FILESDIR}"/99${PN}
}
