# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib

MY_PV=${PV/_beta/-beta\.}

DESCRIPTION="Franz is a free messaging app"
HOMEPAGE="http://meetfranz.com/"
SRC_URI="https://github.com/meetfranz/franz/archive/v${MY_PV}.tar.gz"

SLOT="0"
KEYWORDS="~x86 ~amd64"
LICENSE="Franz"

QA_EXECSTACK="usr*/lib64/${PN}/Franz"
QA_PRESTRIPPED="usr/lib.*/${PN}/lib.*
	usr/lib.*/${PN}/Franz"

DEPEND="dev-libs/libpcre:3
	dev-libs/libtasn1:0
	dev-libs/nettle:0
	dev-libs/nspr:0
	dev-libs/nss:0
	media-libs/libpng:0
	net-libs/gnutls:0
	>=sys-devel/gcc-4.6.0:*
	x11-libs/gtk+:2"

RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	insinto "/usr/$(get_libdir)/${PN}"
	doins -r *.pak *.so *.bin *.dat locales resources Franz
	fperms 755 "/usr/$(get_libdir)/${PN}/Franz"

	doicon -s scalable resources/app.asar.unpacked/assets/franz.svg
	doicon resources/app.asar.unpacked/assets/franz.png

	make_wrapper franz "/usr/$(get_libdir)/${PN}/Franz"
	make_desktop_entry franz Franz franz
}
