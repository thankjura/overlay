# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

DESCRIPTION="Git extensions supporting an advanced branching model"
GITHUB_USER="nvie"
GITHUB_TAG="${PV}"
HOMEPAGE="https://github.com/${GITHUB_USER}/${PN}"
SRC_URI="https://github.com/${GITHUB_USER}/${PN}/tarball/${GITHUB_TAG} -> ${P}.tar.gz"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+completion"

RDEPEND="completion? ( dev-vcs/git-flow-completion )
	>=dev-libs/shflags-1.0.3"

src_prepare() {
	cd "${WORKDIR}"/${GITHUB_USER}-${PN}-*
	S="$(pwd)"

	sed -i \
		-e '/^export GITFLOW_DIR=/s|$(dirname "$0")|/usr/libexec/git-flow|' \
		-e "s|\$GITFLOW_DIR/gitflow-common|/usr/$(get_libdir)/gitflow-common|" \
		-e "s|\$GITFLOW_DIR/gitflow-shFlags|/usr/$(get_libdir)/shflags|" \
		git-flow || die "sed failed"

}

src_compile() { :; }

src_install() {
	exeinto /usr/bin
	doexe git-flow || die "doexe failed"

	insinto /usr/libexec/git-flow
	doins git-flow-* || die "doins failed"

	dolib gitflow-common || die "dolib failed"
	dodoc README.mdown
}
