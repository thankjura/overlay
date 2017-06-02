# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="Python OTR library"
HOMEPAGE="http://sipsimpleclient.org"
SRC_URI="https://github.com/AGProjects/python-otr/archive/release-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-release-${PV}"

LICENSE="GPL-3"
SLOT="0"
IUSE="libressl"

KEYWORDS="~amd64 ~x86"

CDEPEND="
	dev-python/python-application[${PYTHON_USEDEP}]
	dev-python/gmpy:2[${PYTHON_USEDEP}]
"
RDEPEND="${CDEPEND}
	dev-python/zope-interface[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
"
DEPEND="${CDEPEND}
	dev-python/cython[${PYTHON_USEDEP}]
	virtual/pkgconfig
"

#src_unpack() {
#	unpack ${A}
#}
