# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit virtualx gnome2

DESCRIPTION="GNOME-Shell extension that shows a mail indicator in the top panel"
HOMEPAGE="https://github.com/pulb/mailnag-gnome-shell"
SRC_URI="https://github.com/pulb/mailnag-gnome-shell/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-libs/folks
	mail-client/mailnag
"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply ${FILESDIR}/fix-makefile.patch
	eapply ${FILESDIR}/${P}-bump-to-3.24.patch
	default
}

src_configure() {
	default
}

src_compile() {
	emake prefix=/usr
}

src_install() {
	emake prefix=${D}/usr install
	"${EROOT}${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/schemas" || die
}
