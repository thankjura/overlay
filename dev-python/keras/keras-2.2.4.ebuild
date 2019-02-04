# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_6 )
inherit distutils-r1

DESCRIPTION="A high-level neural networks API to several backends"
HOMEPAGE="https://keras.io"
SRC_URI="https://github.com/keras-team/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/h5py[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.9.1[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	>=sci-libs/keras-applications-1.0.6[${PYTHON_USEDEP}]
	>=sci-libs/keras-preprocessing-1.0.5[${PYTHON_USEDEP}]
	sci-libs/scipy[${PYTHON_USEDEP}]
"

RDEPEND="${DEPEND}"
BDEPEND=""

pkg_postinst(){
	ewarn "To run keras you need one of the supported backends: TensorFlow, CNTK, or Theano."
	ewarn "At least sci-libs/tensorflow is part of the main tree."
}
