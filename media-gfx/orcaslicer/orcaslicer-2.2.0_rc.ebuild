# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
MY_PN="OrcaSlicer"
MY_PV=${PV/_/-}

inherit cmake wxwidgets xdg

SRC_URI="https://github.com/SoftFever/OrcaSlicer/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~arm64 ~x86"
S="${WORKDIR}/${MY_PN}-${MY_PV}"

DESCRIPTION="open source slicer for FDM printers"
HOMEPAGE="https://github.com/SoftFever/OrcaSlicer"

LICENSE="AGPL-3 Boost-1.0"
SLOT="0"

RDEPEND="
	media-libs/glfw
	dev-cpp/eigen:3
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/mpfr:=
	media-gfx/openvdb:=
	x11-libs/wxGTK[curl]
	media-libs/mesa[osmesa]
	media-libs/glew:0=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:0=
	media-libs/qhull:=
	net-misc/curl
	sci-libs/opencascade:=
	sci-mathematics/cgal:=
	sys-apps/dbus
	sys-libs/zlib:=
	virtual/opengl
	x11-libs/gtk+:3
	>=x11-libs/wxGTK-3.2.2.1-r3:${WX_GTK_VER}[X,opengl,webkit]
	media-libs/nanosvg:=
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
"

PATCHES=(
	"${FILESDIR}/orcaslicer-2.2.0-fix-build.patch"
	"${FILESDIR}/orcaslicer-2.2.0-fix-wx.patch"
	"${FILESDIR}/orcaslicer-2.2.0-fix-install-path.patch"
	"${FILESDIR}/7057.patch"
)

src_prepare() {
	eapply_user
	append-cxxflags -Wno-error=template-id-cdtor
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	setup-wxwidgets

	local mycmakeargs=(
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		-DCMAKE_INSTALL_PATH="/opt/${MY_PN}"

		-DBBL_RELEASE_TO_PUBLIC=1
		-DBBL_INTERNAL_TESTING=0
		-DORCA_TOOLS=ON
		-DSLIC3R_FHS=1
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=ON
		-DSLIC3R_PCH=OFF
		-DSLIC3R_STATIC=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile OrcaSlicer
	cmake_src_compile OrcaSlicer_profile_validator
	./run_gettext.sh
}
