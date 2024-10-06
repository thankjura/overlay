# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
ORCA_WX_DEPS_COMMIT="5c55131cbfbfb15ddbc1dca3f0567fc18fd15db5"
MY_PN="OrcaSlicer"
MY_PV=${PV/_/-}

inherit cmake wxwidgets xdg


SRC_URI="
	https://github.com/SoftFever/OrcaSlicer/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz
	https://github.com/SoftFever/Orca-deps-wxWidgets/archive/${ORCA_WX_DEPS_COMMIT}.zip -> ${P}_wx_deps.zip"
KEYWORDS="~amd64 ~arm64 ~x86"
S="${WORKDIR}/${MY_PN}-${MY_PV}"

DESCRIPTION="open source slicer for FDM printers"
HOMEPAGE="https://github.com/SoftFever/OrcaSlicer"

LICENSE="AGPL-3 Boost-1.0"
SLOT="0"

RDEPEND="
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
	#"${FILESDIR}/orcaslicer-2.2.0-fix-wx-deps.patch"
	"${FILESDIR}/orcaslicer-2.2.0-fix-install-path.patch"
)

CMAKE_IN_SOURCE_BUILD=1

src_prepare() {
	eapply_user
	append-cxxflags -Wno-error=template-id-cdtor
	cmake_src_prepare
}

src_configure() {
	BUILD_DIR=${WORKDIR}/wxbuild
	local mycmakeargs=(
		-DwxUSE_PRIVATE_FONTS=1
		-DwxBUILD_TOOLKIT=gtk3
		-DwxUSE_WEBVIEW_EDGE=OFF
		-DwxBUILD_PRECOMP=ON
		"-DCMAKE_DEBUG_POSTFIX:STRING="
		-DwxBUILD_DEBUG_LEVEL=0
		-DwxBUILD_SAMPLES=OFF
		-DwxBUILD_SHARED=OFF
		-DwxUSE_MEDIACTRL=ON
        -DwxUSE_DETECT_SM=OFF
        -DwxUSE_UNICODE=ON
        -DwxUSE_OPENGL=ON
        -DwxUSE_WEBREQUEST=ON
        -DwxUSE_WEBVIEW=ON
        -DwxUSE_WEBVIEW_IE=OFF
        -DwxUSE_REGEX=builtin
        -DwxUSE_LIBXPM=builtin
        -DwxUSE_LIBSDL=OFF
        -DwxUSE_XTEST=OFF
        -DwxUSE_STC=OFF
        -DwxUSE_AUI=ON
        -DwxUSE_LIBPNG=sys
        -DwxUSE_ZLIB=sys
        -DwxUSE_LIBJPEG=sys
        -DwxUSE_LIBTIFF=sys
        -DwxUSE_NANOSVG=OFF
        -DwxUSE_EXPAT=sys
		-DCMAKE_INSTALL_PREFIX="${WORKDIR}"/deps_linux
		#-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		#-Wno-dev
	)

	CMAKE_USE_DIR="${WORKDIR}/Orca-deps-wxWidgets-${ORCA_WX_DEPS_COMMIT}" BUILD_DIR= cmake_src_configure

	local mycmakeargs=(
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		-DCMAKE_INSTALL_PATH="/opt/${MY_PN}"
		-DCMAKE_PREFIX_PATH="${WORKDIR}/deps_linux/usr/local"

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

	CMAKE_USE_DIR="${S}" cmake_src_configure
}

src_compile() {
	cmake_src_compile
	#cmake_src_compile OrcaSlicer
	#cmake_src_compile OrcaSlicer_profile_validator
	./run_gettext.sh
}
