# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="2D CAD application"
HOMEPAGE="http://www.qcad.org/"

SRC_URI="https://github.com/qcad/qcad/archive/v${PV}.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

LINGUAS=( de en es fr it ja nl pl pt ru sl )
IUSE=""

for lingua in ${LINGUAS[*]}; do
    IUSE+=" linguas_${lingua}"
done

DEPEND="
    dev-qt/qthelp
    dev-db/sqlite:3
    dev-lang/orc
    dev-libs/expat
    dev-libs/glib
    dev-libs/icu
    dev-libs/libffi
    dev-libs/libxml2
    dev-libs/openssl
    dev-qt/designer
    dev-qt/qtgui
    dev-qt/qthelp
    dev-qt/qtopengl
    dev-qt/qtscript
    dev-qt/qtsql
    dev-qt/qtsvg
    dev-qt/qtwebkit
    dev-qt/qtxmlpatterns
    media-libs/glu
    media-libs/gst-plugins-base
    media-libs/gstreamer
    media-libs/libpng
    media-libs/mesa
    media-libs/nas
    sys-apps/util-linux
"
RDEPEND="${DEPEND}"

src_configure () {
    qmake -r || die
}

src_install () {
    cd "${S}"
    for lingua in "${LINGUAS[@]}"
    do
        if ! use linguas_${lingua}
        then
            find -type f -name "*_${lingua}.*" -delete
        fi
    done

    dobin ${FILESDIR}/qcad

    insinto /usr/lib/${PN}/
    doins -r scripts fonts patterns libraries linetypes ts
    insopts -m0755
    doins release/*
    doins -r plugins

    docinto examples
    dodoc examples/*
    docompress -x /usr/share/doc/${PF}/examples

}
