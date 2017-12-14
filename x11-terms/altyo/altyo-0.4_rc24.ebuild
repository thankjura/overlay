# Lara Maia <lara@craft.net.br> 2015
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DESCRIPTION="A drop-down terminal emulator, written in vala"
HOMEPAGE="https://github.com/linvinus/AltYo"
SRC_URI="https://github.com/linvinus/AltYo/archive/debian/${PV}-linvinus1.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-libs/vte:2.91[introspection,vala]
         >=x11-libs/gtk+-3.4
         >=dev-libs/glib-2.32
         >=dev-lang/vala-0.26"

S="${WORKDIR}/AltYo-debian-${PV}-linvinus1"
