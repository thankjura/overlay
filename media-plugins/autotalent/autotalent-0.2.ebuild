# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit multilib

DESCRIPTION="Realtime pitch correction plugin"
HOMEPAGE="http://tombaran.info/autotalent.html"
SRC_URI="http://tombaran.info/autotalent-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="media-libs/ladspa-sdk"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/$(get_libdir)/ladspa
	doins *.so
	dodoc README
}
