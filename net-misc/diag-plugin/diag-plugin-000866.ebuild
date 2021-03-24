# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Diag.Plugin from SKB Kontur"
HOMEPAGE="https://help.kontur.ru/"
SRC_URI="https://help.kontur.ru/files/diag.plugin_amd64.${PV}.deb"

LICENSE="Proprietary"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack(){
	unpack "${A}"
	unpack ./data.tar.xz
	rm *.tar.gz debian-binary
}

src_install() {
	cp -r etc ${D}/etc
	cp -r opt ${D}/opt
	cp -a usr ${D}/usr
}
