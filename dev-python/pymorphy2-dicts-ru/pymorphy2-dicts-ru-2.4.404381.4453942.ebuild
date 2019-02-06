# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{6,7} )
inherit distutils-r1

MY_PN=

DESCRIPTION="Russian dictionaries for pymorphy2."
HOMEPAGE="https://github.com/kmike/pymorphy2-dicts/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-python/pymorphy2-dicts-2.4[${PYTHON_USEDEP}]
"

RDEPEND="${DEPEND}"
BDEPEND=""
