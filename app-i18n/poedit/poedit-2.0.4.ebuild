# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
WX_GTK_VER=3.0-gtk3

PLOCALES="an ar az be be@latin bg bs ca ckb co cs da de el en_GB es et eu fa fi fr ga gl he hr hu hy id is it ja ka kab kk ko lt lv ms nb nl oc pa pl pt_BR pt_PT ro ru sk sl sq sr sv tg th tr uk uz vi zh_CN zh_TW"

inherit fdo-mime l10n wxwidgets

DESCRIPTION="GUI editor for gettext translations files"
HOMEPAGE="https://poedit.net"
SRC_URI="https://github.com/vslavik/${PN}/releases/download/v${PV}-oss/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc64 ~x86"
IUSE=""

# db/expat req for legacytm (backwards support for pre 1.6)
# we currently have 1.5.5 in stable so this is enabled
RDEPEND="
	app-text/gtkspell:3
	dev-cpp/lucene++
	dev-libs/boost:=[nls]
	dev-libs/expat
	dev-libs/icu:=
	sys-libs/db[cxx]
	x11-libs/gtk+:3
	>=x11-libs/wxGTK-3.0.3:${WX_GTK_VER}[X]
	"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	my_rm_loc() {
		sed -i -e "/^POEDIT_LINGUAS = /s: ${1}::" locales/Makefile.in || die
		rm "locales/${1}.mo" || die
	}
	l10n_find_plocales_changes 'locales' '' '.mo'
	l10n_for_each_disabled_locale_do my_rm_loc

	setup-wxwidgets
	default
}

src_configure() {
	econf --without-cpprest --without-cld2
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS NEWS README
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
