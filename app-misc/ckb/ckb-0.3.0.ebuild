# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils systemd

DESCRIPTION="Corsair K65/K70/K95 Driver"
HOMEPAGE="https://github.com/ckb-next/ckb-next"
SRC_URI="https://github.com/ckb-next/ckb-next/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-libs/quazip-0.7.2[qt5(+)]
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5"
RDEPEND="${DEPEND}"

S=${WORKDIR}/ckb-next-${PV}

#src_prepare() {
#	sed -i -e "s#/usr/lib#/usr/libexec#" src/ckb/animscript.cpp || die
#}


#src_install() {
#	dobin bin/ckb bin/ckb-daemon
#	dodir /usr/bin/ckb-animations
#	exeinto /usr/libexec/ckb-animations
#	doexe bin/ckb-animations/*
#
#	newinitd "${FILESDIR}"/ckb.initd ckb-daemon
#	domenu usr/ckb.desktop
#	doicon usr/ckb.png
#	systemd_dounit service/systemd/ckb-daemon.service
#}
