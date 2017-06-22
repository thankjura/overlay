# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils git-r3

KEYWORDS=""
if [[ ${PV} != 9999* ]]; then
	EGIT_COMMIT=${PV}
fi

DESCRIPTION="Ethereum and other technologies to provide a decentralised application framework"
HOMEPAGE="https://www.ethereum.org"
EGIT_REPO_URI="https://github.com/ethereum/cpp-ethereum.git"

LICENSE="MIT ISC GPL-3+ LGPL-3+ BSD-2 public-domain"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"

DEPEND="
	>=dev-libs/gmp-6:=
	>=sys-devel/clang-3.7
	>=sys-devel/llvm-3.7
	net-libs/libmicrohttpd

	dev-cpp/libjson-rpc-cpp[stubgen,http-client,http-server]
	dev-libs/boost
	dev-libs/crypto++
	dev-libs/jsoncpp
	dev-libs/leveldb[snappy]
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwebengine:5
	dev-qt/qtwebkit:5
	dev-qt/qtwidgets:5
	dev-util/scons
	net-libs/miniupnpc
	net-misc/curl
	sys-libs/ncurses:0[tinfo]
	sys-libs/readline:0
	virtual/opencl
"
RDEPEND="${DEPEND}"

CMAKE_MIN_VERSION="3.2"

PATCHES="${FILESDIR}/*.patch"

src_prepare() {
	git submodule update --init --recursive

	cmake-utils_src_prepare

	sed -i \
		-e "s:llvm_map_components_to_libnames:explicit_map_components_to_libraries:" \
		evmjit/CMakeLists.txt || die "sed failed"

	epatch_user
}
