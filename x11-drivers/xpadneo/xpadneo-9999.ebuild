# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod linux-info git-r3 udev

DESCRIPTION="Advanced Linux Driver for Xbox One Wireless Controller"
HOMEPAGE="https://github.com/atar-axis/xpadneo"
SRC_URI=""
EGIT_REPO_URI="https://github.com/atar-axis/xpadneo.git"
EGIT_BRANCH="master"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S=${S}/hid-xpadneo/src

MODULE_NAMES="hid-xpadneo(hid:)"
BUILD_TARGETS="modules"
#BUILD_PARAMS="KDIR=${KV_OUT_DIR} M=${S}"

pkg_setup() {
	linux-mod_pkg_setup
}

src_configure() {
	set_arch_to_kernel
}

src_compile() {
	emake -C ${KV_OUT_DIR} M=${S} modules
}

src_install() {
	linux-mod_src_install
	udev_newrules ${S}/etc-udev-rules.d/98-xpadneo.rules 98-xpadneo.rules
}
