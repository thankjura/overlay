# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3 udev

DESCRIPTION="Adds loopback and LED control to headsets"
HOMEPAGE="https://github.com/Sapd/HeadsetControl"
SRC_URI=""
EGIT_REPO_URI="https://github.com/Sapd/HeadsetControl"

if [[ ${PV} = 9999 ]] ; then
	EGIT_COMMIT=""
else
	EGIT_COMMIT="${PV}"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="udev"

DEPEND="
dev-util/cmake
dev-libs/hidapi
udev? ( virtual/udev )
"
RDEPEND=""
BDEPEND=""

CMAKE_MAKEFILE_GENERATOR="emake"

src_prepare() {
	default
	# upstream generates the udev files by call to headsetcontrol binary with -u flag
	# this triggers sandbox violation
	# this changes the output of rules file to a temporary location, and the rules are installed later
	sed -i "s;/etc/udev/rules.d;${T};" "${WORKDIR}/${P}/CMakeLists.txt" || die "Failed to replace the udev rules location"
	cmake_src_prepare
}

src_install() {
	default
	cmake_src_install
	if use udev; then
		# fixes 'invalid argument?' error in udev rules
		# this command is the same one used in makefile
		"${WORKDIR}/${P}_build"/headsetcontrol -u > "${T}/70-headsets.rules"
		udev_dorules "${T}/70-headsets.rules"
	fi
}

pkg_postinst() {
	if use udev; then
		udev_reload
	fi
}
