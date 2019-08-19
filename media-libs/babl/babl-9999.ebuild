# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == *9999* ]]; then
	inherit autotools git-r3 meson
	EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/babl.git"
	SRC_URI=""
else
	SRC_URI="http://ftp.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"

LICENSE="LGPL-3"
SLOT="0"
IUSE="+lcms cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_sse4_1 cpu_flags_x86_mmx cpu_flags_x86_f16c cpu_flags_x86_avx2 doc"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-D enable-mmx=$(usex cpu_flags_x86_mmx true false)
		-D enable-sse=$(usex cpu_flags_x86_sse true false)
		-D enable-sse2=$(usex cpu_flags_x86_sse2 true false)
		-D enable-sse3=$(usex cpu_flags_x86_sse3 true false)
		-D enable-sse4_1=$(usex cpu_flags_x86_sse4_1 true false)
		-D enable-avx2=$(usex cpu_flags_x86_avx2 true false)
		-D enable-f16c=$(usex cpu_flags_x86_f16c true false)
		-D enable-gir=true
		-D with-docs=$(usex doc true false)
		-D with-lcms=$(usex lcms true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	find "${D}" -name '*.la' -type f -delete || die
}
