# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils pax-utils gnome2-utils xdg-utils

DESCRIPTION="The most intuitive cross-platform REST API Client"
HOMEPAGE="https://insomnia.rest/"
SRC_URI="https://github.com/getinsomnia/insomnia/releases/download/v${PV}/insomnia_${PV}_amd64.deb"
LICENSE="Insomnia"
RESTRICT="mirror"

SLOT="0"
KEYWORDS="~amd64 -*"
IUSE=""

QA_PREBUILT="usr/lib/slack/*"

DEPEND=""
RDEPEND="
	gnome-base/gconf
	x11-libs/libnotify
	dev-libs/libappindicator
	x11-libs/libXtst
	dev-libs/nss
"

S="${WORKDIR}"

src_unpack() {
	ar x "${DISTDIR}/${A}" || die
	unpack "${WORKDIR}/data.tar.xz"
}


src_install() {
	unpack usr/share/doc/insomnia/*.gz
	dodoc changelog

	insinto /usr/share
	doins -r usr/share/icons
	doins -r usr/share/applications

	cp -a opt "${D}" || die
	pax-mark rm "${ED}/opt/Insomnia/insomnia"
	make_wrapper "${PN}" "/opt/Insomnia/insomnia"
}

pkg_postinst() {
    gnome2_icon_cache_update
    xdg_desktop_database_update
}

pkg_postrm() {
    gnome2_icon_cache_update
    xdg_desktop_database_update
}
