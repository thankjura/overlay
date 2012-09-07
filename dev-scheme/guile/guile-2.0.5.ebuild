# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/guile/guile-2.0.0.ebuild,v 1.2 2011/04/12 18:20:24 mr_bones_ Exp $

EAPI=4
inherit autotools eutils flag-o-matic elisp-common

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="LGPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="networking +regex +deprecated emacs nls debug-malloc debug +threads"

DEPEND="
	app-admin/eselect-guile
	dev-libs/gmp
	>=sys-devel/libtool-1.5.6
	sys-devel/gettext
	dev-libs/libunistring
	>=dev-libs/boehm-gc-7.0[threads?]
	dev-libs/libffi
	emacs? ( virtual/emacs )
	virtual/pkgconfig"
RDEPEND="${DEPEND}"

SLOT="2"
MAJOR="2.0"

src_prepare() {
	epatch "${FILESDIR}/3742d778fbc6ea879437c19aeebe09179dceffdf.patch"
	epatch_user
	eautoreconf
}

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
		--with-modules # \
#		EMACS=no
}

src_compile()  {
	emake || die "make failed"

	# Above we have disabled the build system's Emacs support;
	# for USE=emacs we compile (and install) the files manually
	# if use emacs; then
	# 	cd emacs
	# 	make
	# 	elisp-compile *.el || die
	# fi
}

src_install() {
	einstall infodir="${ED}"/usr/share/info/guile-${MAJOR} || die "install failed"

	# Maybe there is a proper way to do this? Symlink handled by eselect
	mv "${ED}"/usr/share/aclocal/guile.m4 "${ED}"/usr/share/aclocal/guile-${MAJOR}.m4 || die "rename of guile.m4 failed"

	dodoc AUTHORS ChangeLog GUILE-VERSION HACKING NEWS README THANKS || die

	# Replaced by app-admin/eselect-guile
	## texmacs needs this, closing bug #23493
	#dodir /etc/env.d
	#echo "GUILE_LOAD_PATH=\"${EPREFIX}/usr/share/guile/${MAJOR}\"" > "${ED}"/etc/env.d/50guile

	# necessary for registering slib, see bug 206896
	keepdir /usr/share/guile/site

	# if use emacs; then
	# 	elisp-install ${PN} emacs/*.{el,elc} || die
	# 	elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el" || die
	# fi
}

pkg_postinst() {
	[ "${EROOT}" == "/" ] && pkg_config
	use emacs && elisp-site-regen
	eselect guile update ifunset
}

pkg_postrm() {
	use emacs && elisp-site-regen
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
