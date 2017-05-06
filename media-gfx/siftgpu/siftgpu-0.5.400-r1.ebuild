# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/siftgpu/siftgpu-0.5.400.ebuild,v 0.1 2013/11/19 11:24:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="A GPU Implementation of SIFT"
HOMEPAGE="http://cs.unc.edu/~ccwu/siftgpu/"

COMMIT="6f1bde2aef070c8a1cae8a779081e9c1319da192"

SRC_URI="https://github.com/W-Floyd/SiftGPU/archive/${COMMIT}.zip -> SiftGPU-V400.zip"

LICENSE="UNC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda"

DEPEND="media-libs/glew
		media-libs/devil
		cuda? ( dev-util/nvidia-cuda-toolkit )"
RDEPEND="${DEPEND}"

MAKEOPTS="-j1"

S="${WORKDIR}/SiftGPU"

src_unpack() {
	default	
	cd ${WORKDIR}
	mv SiftGPU-6f1bde2aef070c8a1cae8a779081e9c1319da192 SiftGPU || die
}

src_prepare() {
	export CUDA_INSTALL_PATH=/opt/cuda
	export siftgpu_prefer_glut=1
	if use cuda ; then
		export siftgpu_enable_cuda=1
	else
		export siftgpu_enable_cuda=2
	fi
	rm -r include
	sed -i -e's/siftgpu_prefer_glut = 0/siftgpu_prefer_glut = 1/' makefile
}

src_install() {
	dobin "${S}"/bin/MultiThreadSIFT "${S}"/bin/SimpleSIFT "${S}"/bin/speed
	dolib "${S}"/bin/libsiftgpu.so
	insinto /usr/include
	doins "${S}"/bin/libsiftgpu.a
	dodoc -r doc data demos
}
