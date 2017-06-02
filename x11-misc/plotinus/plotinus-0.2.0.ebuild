# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
VALA_MIN_API_VERSION="0.26"

inherit cmake-utils vala

DESCRIPTION="A searchable command palette in every modern GTK+ application"
HOMEPAGE="https://github.com/p-e-w/plotinus"
SRC_URI="https://github.com/p-e-w/plotinus/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="$(vala_depend)
>=x11-libs/gtk+-3.20.9"
RDEPEND="${DEPEND}"

src_prepare() {
    vala_src_prepare
    sed -i -e "/NAMES/s:valac:${VALAC}:" cmake/FindVala.cmake || die
    echo "GTK3_MODULES=\"${EPREFIX}/usr/lib/libplotinus.so\"" > "${S}"/99plotinus
    cmake-utils_src_prepare
}

src_install() {
    dolib.so "${BUILD_DIR}"/libplotinus.so
    doenvd "${S}"/99plotinus
}

