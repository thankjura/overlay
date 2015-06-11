# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic
#inherit git-2

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"
#EGIT_REPO_URI="git://git.sv.gnu.org/guile.git"
#EGIT_MASTER="stable-2.0"

LICENSE="LGPL-3"
KEYWORDS=""
IUSE="doc networking +regex +deprecated nls debug-malloc debug +threads"

RDEPEND="
	app-admin/eselect-guile
	>=dev-libs/boehm-gc-7.0[threads?]
	dev-libs/gmp:0
	dev-libs/libffi
	dev-libs/libunistring
	sys-devel/gettext
	>=sys-devel/libtool-1.5.6
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( sys-apps/texinfo )
"

SLOT="2"
MAJOR="2"

#src_prepare() {
#	# for live ebuilds
#	if [ -x autogen.sh ]; then
#		./autogen.sh || die
#	fi
#}

src_configure() {
	# see bug #178499
	filter-flags -ftree-vectorize

	#will fail for me if posix is disabled or without modules -- hkBst
	econf \
		--program-suffix="-${MAJOR}" \
		--infodir="${EPREFIX}"/usr/share/info/guile-${MAJOR} \
		--disable-error-on-warning \
		--disable-static \
		--enable-posix \
		$(use_enable networking) \
		$(use_enable regex) \
		$(use_enable deprecated) \
		$(use_enable nls) \
		--disable-rpath \
		$(use_enable debug-malloc) \
		$(use_enable debug guile-debug) \
		$(use_with threads) \
		--with-modules
}

src_compile()  {
	emake || die "make failed"
}

src_install() {
	einstall infodir="${ED}"/usr/share/info/guile-${MAJOR} || die "install failed"

	# Maybe there is a proper way to do this? Symlink handled by eselect
	mv "${ED}"/usr/share/aclocal/guile.m4 "${ED}"/usr/share/aclocal/guile-${MAJOR}.m4 || die "rename of guile.m4 failed"

	dodoc AUTHORS ChangeLog GUILE-VERSION HACKING NEWS README THANKS || die

	# necessary for registering slib, see bug 206896
	keepdir /usr/share/guile/site

	use doc && {
		make -C doc html MAKEINFOHTML='makeinfo --html --no-split' || {
			die "\`make -C doc html' failed"
		}
		dohtml doc/ref/guile.html doc/r5rs/r5rs.html
	}
}

pkg_postinst() {
	[ "${EROOT}" == "/" ] && pkg_config
	eselect guile update ifunset
}

pkg_postrm() {
	eselect guile update ifunset
}

pkg_config() {
	if has_version dev-scheme/slib; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}

_pkg_prerm() {
	rm -f "${EROOT}"/usr/share/guile/site/slibcat
}
