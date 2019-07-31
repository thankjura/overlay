# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Framework for achieving optimal ray tracing performance on the GPU"
HOMEPAGE="https://developer.nvidia.com/optix"
SRC_URI="NVIDIA-OptiX-SDK-${PV}-linux64.sh"
RESTRICT="fetch"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/nvidia-cuda-toolkit"
RDEPEND="${DEPEND}"

src_unpack() {
	sh "${DISTDIR}"/${A} --prefix="${WORKDIR}" --exclude-subdir || die
}

S=${WORKDIR}

src_install() {
	mkdir -p "${D}/opt/optix"
	cp -a ${WORKDIR}/* "${D}/opt/optix"
	mkdir -p "${D}/usr/share/licenses/${PN}"
	dosym /opt/optix/doc/OptiX_EndUserLicense.pdf /usr/share/licenses/${PN}/OptiX_EndUserLicense.pdf
}
