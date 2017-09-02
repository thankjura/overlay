# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit versionator

MY_PV=$(replace_version_separator 1 '_' )

DESCRIPTION="Portable and retargetable 6502 6800 arm c16x jagrisc m68k ppc test tr3200 vidcore x86 z80 assembler."
HOMEPAGE="http://sun.hasenbraten.de/vasm/"
SRC_URI="http://server.owl.de/~frank/tags/${PN}${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

CPU_LIST="6502 6800 arm c16x jagrisc m68k ppc test tr3200 vidcore x86 z80"
SYNTAX_LIST="std madmac mot oldstyle" # test
OUTPUT_LIST="aout bin elf hunk test tos vobj"

S=${WORKDIR}/${PN}

src_compile() {
	for CPU in ${CPU_LIST}; do
    	for SYNTAX in ${SYNTAX_LIST}; do
      		make CPU=${CPU} SYNTAX=${SYNTAX}
	    done
	done
}

src_install() {
	for CPU in ${CPU_LIST}; do
    	for SYNTAX in ${SYNTAX_LIST}; do
      		dobin vasm${CPU}_${SYNTAX}
		done
	done
}
