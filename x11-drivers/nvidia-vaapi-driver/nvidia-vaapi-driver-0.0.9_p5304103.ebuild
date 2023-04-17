# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

NV_VIN=${PVR#*_p}
NV_VER=${NV_VIN:0:3}.${NV_VIN:3:(-2)}.${NV_VIN:(-2)}
MY_PV=${PVR%%_*}

DESCRIPTION="VA-API implementation that uses NVDEC as a backend"
HOMEPAGE="https://github.com/elFarto/nvidia-vaapi-driver/"
SRC_URI="
	https://github.com/elFarto/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz
	https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${NV_VER}.tar.gz -> open-gpu-kernel-modules-${NV_VER}.tar.gz
"

IUSE="+direct"
LICENSE="MIT Expat"
KEYWORDS="~amd64"
SLOT="530/30.02"

BDEPEND="
	|| (
		!!<x11-drivers/nvidia-drivers-${NV_VER}
		!!>x11-drivers/nvidia-drivers-${NV_VER}
	)
	!<x11-drivers/nvidia-vaapi-driver-${MY_PV}_p0
	media-libs/nv-codec-headers
	media-video/ffmpeg[nvenc]
"
RDEPEND="
	=x11-drivers/nvidia-drivers-${NV_VER}
"
S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	default
	cp ${FILESDIR}/99nvidia-vaapi ${S}/99nvidia-vaapi
	if use direct; then
		echo "Enabeling direct access.."
        "./${S}/extract_headers.sh" "${WORKDIR}/open-gpu-kernel-modules-${NV_VER}"
        echo "NVD_BACKEND=direct" >> ${S}/99nvidia-vaapi
    fi
}

src_install() {
	meson_src_install
	dosym /usr/lib64/dri/nvidia_drv_video.so /usr/lib64/va/drivers/nvidia_drv_video.so
	doenvd ${S}/99nvidia-vaapi
}
