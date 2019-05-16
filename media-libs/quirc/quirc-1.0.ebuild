# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="QR decoder librar"
HOMEPAGE="https://github.com/dlbeer/quirc/"
SRC_URI="https://github.com/dlbeer/quirc/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/libjpeg-turbo"
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	append-flags -fPIC
	emake libquirc.a libquirc.so quirc-scanner
}

src_install() {
	doheader  lib/quirc.h
	dolib.a libquirc.a
	dolib.so libquirc.so.${PV}
	dobin quirc-scanner
}
