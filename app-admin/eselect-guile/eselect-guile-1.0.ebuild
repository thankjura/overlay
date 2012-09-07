# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Manage multiple Guile versions on one system"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/scheme/"
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

# Versions prior to guile-1.8.8-r2 aren't properly slotted
DEPEND=""
RDEPEND=">=app-admin/eselect-1.2.6
	!<dev-scheme/guile-1.8.8-r2"

src_install() {
	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/guile.eselect || die
	doman "${FILESDIR}"/guile.eselect.5 || die
	#dodoc ChangeLog || die
}

src_test() { :; }

pkg_prerm() {
	eselect guile clean
}
