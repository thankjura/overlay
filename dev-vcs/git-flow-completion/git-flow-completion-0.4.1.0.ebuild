# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

DESCRIPTION="git flow completion for bash and zsh"
GITHUB_USER="bobthecow"
GITHUB_TAG="${PV}"
SRC_URI="https://github.com/${GITHUB_USER}/${PN}/tarball/${GITHUB_TAG} -> ${P}.tar.gz"
SRC_HASH="b399150"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+bash zsh"

RDEPEND="app-shells/bash
	zsh? ( app-shells/zsh )
	dev-vcs/gitflow
	${DEPEND}"

S="${WORKDIR}/${GITHUB_USER}-${PN}-${SRC_HASH}"

src_install() {
	insinto /etc/bash_completion.d
	doins git-flow-completion.bash

	if use zsh; then
		insinto /etc/zsh
		doins git-flow-completion.zsh
	fi
}

pkg_postinst() {
	if use zsh; then
		ewarn "To acitvate the git-flow-completion you need to add the following"
		ewarn "to one of your .zshrc files:"
		ewarn ""
		ewarn "\"source /etc/zsh/git-flow-completion.zsh\""
		ewarn ""
		ewarn "If you want to enable it for all users do so in
		\"/etc/zsh/zshrc\"."
	fi
}
