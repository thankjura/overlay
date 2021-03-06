# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit linux-mod bash-completion-r1

DESCRIPTION="Experimental Logitech force feedback module"
HOMEPAGE="https://github.com/berarma/new-lg4ff"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/berarma/${PN}"
else
	SRC_URI="https://github.com/berarma/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	RESTRICT="mirror"
fi

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE="" # dkms

DEPEND=""
RDEPEND="${DEPEND}"

MODULE_NAMES="hid-logitech-new(kernel/drivers/hid:.:.)"
BUILD_TARGETS="default"
CONFIG_CHECK=""

pkg_setup() {
	linux-mod_pkg_setup
}

src_prepare() {
	eapply_user
	sed -i 's!KDIR := .*!KDIR := /lib/modules/'"${KV_FULL}"'/build!g' Makefile
}

src_compile() {
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
}

pkg_postinst() {
	linux-mod_pkg_postinst
}
