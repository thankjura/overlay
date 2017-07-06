# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="Formerly known as Genoil's CUDA miner"
HOMEPAGE="https://github.com/Genoil/cpp-ethereum"
EGIT_REPO_URI="https://github.com/Genoil/cpp-ethereum.git"
EGIT_BRANCH="110"
KEYWORDS="~amd64 ~x86"

LICENSE="MIT ISC GPL-3+ LGPL-3+ BSD-2 public-domain"
SLOT="0"
IUSE="cuda -opencl"

CUDA_SM="30 35 50 52 60 61"

REQUIRED_USE="
	|| ( sm_30 sm_35 sm_50 sm_52 sm_60 sm_61 )
	|| ( opencl cuda )	
"

for X in ${CUDA_SM}; do
	IUSE+=" -sm_${X}"
	REQUIRED_USE+=" sm_${X}? ( cuda )"
done

DEPEND="
	dev-cpp/libjson-rpc-cpp
	dev-util/nvidia-cuda-toolkit
	!net-misc/ethminer
"

CMAKE_MIN_VERSION="3.2"

PATCHES="${FILESDIR}/*.patch"


src_configure() {
	local mycmakeargs=""
	for X in ${CUDA_SM}; do
		if use sm_${X}; then
			mycmakeargs+=(
				-DCOMPUTE=${X}
			)
			break;
		fi
	done
	if use cuda; then
		mycmakeargs+=(
			-DBUNDLE=cudaminer
		)
	fi

	if use opencl; then
		mycmakeargs+=(
			-DBUNDLE=miner
		)
	fi
	cmake-utils_src_configure
}
