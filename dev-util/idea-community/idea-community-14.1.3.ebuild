# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils versionator

SLOT="$(get_major_version)"
RDEPEND=">=virtual/jdk-1.6"

MY_PV="$(get_version_component_range 1-3)"
MY_PN="idea"
MY_PA="community"
MY_PAS="IC"
MY_BUILD="141.1010.3"

#MY_BUILD="$(delete_all_version_separators)"
#MY_BUILD=${MY_BUILD/pre/.}

RESTRICT="strip"
QA_TEXTRELS="opt/${P}/bin/libbreakgen.so"

DESCRIPTION="IntelliJ IDEA is an intelligent Java IDE"
HOMEPAGE="http://jetbrains.com/idea/"
#SRC_URI="http://download.jetbrains.com/${MY_PN}/${MY_PN}${MY_PAS}-$(get_version_component_range 1-3).tar.gz"
#SRC_URI="http://download.jetbrains.com/${MY_PN}/${MY_PN}${MY_PAS}-${MY_BUILD}.tar.gz"
SRC_URI="http://download.jetbrains.com/${MY_PN}/ideaIC-${PV}.tar.gz"
LICENSE="IntelliJ-IDEA"
IUSE=""
KEYWORDS="~x86 ~amd64"
S="${WORKDIR}/${MY_PN}-${MY_PAS}-${MY_BUILD}"

src_prepare() {
    epatch "${FILESDIR}"/idea-run.patch
}

src_install() {
	local dir="/opt/${MY_PN}${MY_PAS}${SLOT}"
	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}/bin/${MY_PN}.sh"
	fperms 755 "${dir}/bin/fsnotifier"
	fperms 755 "${dir}/bin/fsnotifier64"
	local exe=${MY_PN}${MY_PAS}-${SLOT}
	local icon=${exe}.png
	newicon "${S}/bin/${MY_PN}.png" ${icon}
	dodir /usr/bin
	make_wrapper "$exe" "/opt/${MY_PN}${MY_PAS}${SLOT}/bin/${MY_PN}.sh"
	make_desktop_entry ${exe} "IntelliJ IDEA ${PV} ${MY_PA}" /usr/share/pixmaps/${icon} "Development;IDE"
	insinto /etc/intellij-idea
	doins bin/idea.vmoptions || die
}
