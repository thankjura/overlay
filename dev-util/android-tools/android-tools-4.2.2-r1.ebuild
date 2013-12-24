# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/android-tools/android-tools-0_p20130123.ebuild,v 1.1 2013/08/26 09:46:32 zmedico Exp $

EAPI=5
inherit eutils rpm toolchain-funcs

KEYWORDS="~amd64 ~x86 ~arm-linux ~x86-linux"
DESCRIPTION="Android platform tools (adb and fastboot)"
HOMEPAGE="https://android.googlesource.com/platform/system/core.git/"
SRC_URI="android-tools-4.2.2_r1-2.1.2.src.rpm"
# The entire source code is Apache-2.0, except for fastboot which is BSD.
LICENSE="Apache-2.0 BSD"
SLOT="0"
IUSE=""

RDEPEND="sys-libs/zlib:=
	dev-libs/openssl:0="

DEPEND="${RDEPEND}"

S=${WORKDIR}/core-${PV}_r1

src_unpack() {
	rpm_unpack ${A}
	unpack ./core-${PV}_r1.tar.bz2 ./extras-${PV}_r1.tar.bz2
}

src_prepare() {
	mv ../core-Makefile Makefile || die
	mv ../adb-Makefile adb/Makefile || die
	mv ../fastboot-Makefile fastboot/Makefile || die

	# Avoid libselinux dependency.
	sed -e 's: -lselinux::' -i fastboot/Makefile || die
	sed -e '/#include <selinux\/selinux.h>/d' \
		-e 's:#include <selinux/label.h>:struct selabel_handle;:' \
		-i ../extras/ext4_utils/make_ext4fs.h || die
	#sed -e '160,174d;434,455d' -i ../extras/ext4_utils/make_ext4fs.c || die
}

src_install() {
	exeinto /usr/bin
	doexe adb/adb
	doexe fastboot/fastboot
	dodoc adb/{OVERVIEW,SERVICES}.TXT
}
