# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{6,7} )
inherit distutils-r1

DESCRIPTION="Morphological analyzer for Russian language"
HOMEPAGE="https://pymorphy2.readthedocs.io"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-python/docopt-0.6[${PYTHON_USEDEP}]
	>=dev-python/DAWG-Python-0.7.1[${PYTHON_USEDEP}]
	>=dev-python/pymorphy2-dicts-ru-2.4[${PYTHON_USEDEP}]
	<dev-python/pymorphy2-dicts-ru-3[${PYTHON_USEDEP}]
"

RDEPEND="${DEPEND}"
BDEPEND=""
