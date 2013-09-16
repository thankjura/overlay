# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit qt4-r2 subversion

#LANGS="ar_SY bg ca cs de el_GR en_US es et eu fi fr gl hu it ja ka ko ku mk nl
#pl pt_BR pt ro_RO ru_RU sk sl_SI sr sv tr uk_UA vi_VN zh_CN zh_TW"

DESCRIPTION="UMPlayer is the multimedia player that fills all your needs"
HOMEPAGE="http://www.umplayer.com/"
unset SRC_URI
ESVN_REPO_URI="https://umplayer.svn.sourceforge.net/svnroot/umplayer/umplayer/trunk"
ESVN_PROJECT="umplayer"
#ESVN_REVISION="153"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

src_prepare() {
	sed -i -e 's/\$(QMAKE).\$(QMAKE_OPTS).\&\&.//' Makefile || die "Sed failed!"
	sed -i -e 's/PREFIX=\/usr\/local/PREFIX=\/usr/' Makefile || die "Sed failed!"
}
src_configure() {
	cd src/
	eqmake4 
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install || die
}
