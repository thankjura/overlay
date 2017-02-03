# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils rpm

DESCRIPTION="JOXI another screenshot program for linux"
HOMEPAGE="http://joxi.ru"
SRC_URI="http://joxi.ru/K8238OSJ9l75AO?d=1 -> joxi-amd64.deb"
#SRC_URI="http://joxi.ru/JMAje0S4x7Ge2e?d=1 -> joxi-amd64.rpm"
#SRC_URI="http://dl.joxi.ru/linux/joxi-amd64.deb"

LICENSE="JOXI"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-libs/libappindicator:2
	dev-libs/libmcrypt
	dev-qt/qtquickcontrols
	dev-qt/qtwidgets:5
	dev-qt/qtnetwork:5
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtscript:5
	dev-qt/qtx11extras:5
	dev-qt/qtgui:5
	dev-qt/qtcore:5
	x11-libs/libXdamage
	dev-qt/qtdeclarative
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
    unpack ${A}
#    rpm_src_unpack ${A}
    unpack ./data.tar.xz
}

src_compile() {
    :;
}


src_install() {
	newbin usr/bin/joxi joxi

	insinto /usr/share/applications
	doins usr/share/applications/* || die "doins desktop application failed"

	insinto /opt/${PN}
	doins -r opt/${PN}/*
}

