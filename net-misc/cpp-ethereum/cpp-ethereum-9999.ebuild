# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Ethereum miner with CUDA and stratum support"
HOMEPAGE="https://github.com/Genoil/cpp-ethereum"
EGIT_REPO_URI="https://github.com/Genoil/cpp-ethereum.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda opencl"

RDEPEND="cuda? ( dev-util/nvidia-cuda-toolkit )
	>=dev-cpp/libjson-rpc-cpp-0.4[http-server,http-client,stubgen]
	dev-libs/boost
	>=dev-libs/crypto++-5.6.2
	dev-libs/jsoncpp
	dev-libs/libcpuid
	virtual/opencl"
DEPEND="dev-libs/gmp
	dev-libs/leveldb
	net-libs/miniupnpc
	net-misc/curl
	${RDEPEND}
	sys-libs/readline"

src_configure() {
	local mycmakeargs=(
		-DBUNDLE="$(usex cuda cudaminer miner)"
		-DETHASHCL="$(usex opencl ON OFF)"
	)

	cmake-utils_src_configure
}
