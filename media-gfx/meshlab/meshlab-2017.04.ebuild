# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils multilib

MESHLAB_COMMIT="410316f8db7bf0f5a626ed0b227aafe0e2482ab3"
VCG_COMMIT="aada1502e45cdcf63282ae9e4bebc8b00cd1a02e"

DESCRIPTION="A mesh processing system"
HOMEPAGE="http://meshlab.sourceforge.net/"
SRC_URI="https://github.com/cnr-isti-vclab/meshlab/archive/${MESHLAB_COMMIT}.zip -> meshlab-${MESHLAB_COMMIT}.zip
		https://github.com/cnr-isti-vclab/vcglib/archive/${VCG_COMMIT}.zip -> vcglib-${VCG_COMMIT}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="dev-cpp/eigen:3
	dev-cpp/muParser
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	dev-qt/qtxmlpatterns:5
	media-libs/glew
	media-libs/qhull
	=media-libs/lib3ds-1*
	media-libs/openctm
	sci-libs/levmar
	sys-libs/libunwind
	sci-libs/mpir"
RDEPEND="${DEPEND}"

src_unpack() {
	default
	mv vcglib-${VCG_COMMIT} vcglib || die
	mv meshlab-${MESHLAB_COMMIT} meshlab || die
}

src_prepare() {
	cd "${WORKDIR}"
	epatch ${FILESDIR}/*.patch
	QT_SELECT=qt5
}

S="${WORKDIR}/${PN}/src"

src_configure() {
	cd external
	qmake -qt=5 external.pro -r
	cd ../common
	qmake -qt=5 common.pro -r
	cd ../
	qmake -qt=5 meshlab_full.pro -r
}

src_compile() {
	cd external && emake
	cd ../common && emake
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
	newicon "${S}"/meshlab/images/eye64.png "${PN}".png
	make_desktop_entry meshlab "Meshlab"
}
