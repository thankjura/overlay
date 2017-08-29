# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

VCGLIB_VER="1.0.1"

DESCRIPTION="Open source system for processing and editing 3D triangular meshes"
HOMEPAGE="http://www.meshlab.net/"
SRC_URI="https://github.com/cnr-isti-vclab/meshlab/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/cnr-isti-vclab/vcglib/archive/v${VCGLIB_VER}.tar.gz -> vcglib-${VCGLIB_VER}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="dev-cpp/muParser
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	dev-qt/qtscript:5
	=media-libs/lib3ds-1*
	sci-libs/levmar
	virtual/glu
	sci-libs/mpir"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src"

src_prepare() {
	rm -fr src/external/{inc,lib}
	mv plugins_experimental/io_TXT/io_txt.pro plugins_experimental/io_TXT/io_TXT.pro || die
	eapply ${FILESDIR}/${PV}/*.patch
	mv ${WORKDIR}/vcglib-${VCGLIB_VER} ${WORKDIR}/vcglib
	cd ${WORKDIR}/vcglib
	eapply ${FILESDIR}/vcglib_import_bundle_out.patch
	default
}

src_configure() {
	export QT_SELECT=qt5
	cd external && qmake -recursive external.pro
	cd .. && qmake -recursive meshlab_full.pro
}

src_compile() {
	cd external && emake
	cd .. && emake
}

src_install() {
	dobin distrib/{meshlab,meshlabserver}
	dolib distrib/libcommon.so.1.0.0
	dosym libcommon.so.1.0.0 /usr/$(get_libdir)/libcommon.so.1
	dosym libcommon.so.1 /usr/$(get_libdir)/libcommon.so

	exeinto /usr/$(get_libdir)/meshlab/plugins
	doexe distrib/plugins/*.so

	insinto /usr/share/meshlab/shaders
	doins -r distrib/shaders/*
	insinto /usr/share/meshlab/textures
	doins -r distrib/textures/*
	insinto /usr/share/meshlab/sample
	doins -r distrib/sample/*

	doman ../docs/meshlab.1
	doman ../docs/meshlabserver.1

	newicon "${S}"/meshlab/images/eye_cropped.png "${PN}".png
	make_desktop_entry meshlab "Meshlab"
}
