# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/cmvs/cmvs-2.ebuild,v 0.3 2014/11/21 09:30:12 brothermechanic Exp $

EAPI=5

inherit eutils cmake-utils git-r3

DESCRIPTION="Clustering Views for Multi-view Stereo"
HOMEPAGE="http://www.di.ens.fr/cmvs/"
#SRC_URI="http://www.di.ens.fr/cmvs/cmvs-fix2.tar.gz"
EGIT_REPO_URI="https://github.com/soulsheng/CMVS-PMVS.git"
EGIT_BRANCH="master"
EGIT_COMMIT="c175e00b2cc17d14f2a3421030c24f206326d49e"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sci-libs/clapack
	dev-libs/libf2c
	media-libs/graclus
	dev-libs/boost
	sci-libs/gsl
	virtual/blas
	virtual/jpeg:*"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/program/"

src_install() {
	exeinto /opt/vsfm
	doexe "${BUILD_DIR}"/main/pmvs2 "${BUILD_DIR}"/main/cmvs "${BUILD_DIR}"/main/genOption
}
