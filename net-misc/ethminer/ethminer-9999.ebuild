# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="The ethminer is an Ethereum GPU mining worker"
HOMEPAGE="https://github.com/ethereum-mining/ethminer"
EGIT_REPO_URI="https://github.com/ethereum-mining/ethminer.git"
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
			-DETHASHCUDA=ON
		)
	fi

	if use opencl; then
		mycmakeargs+=(
			-DETHASHCL=ON
		)
	fi
	mycmakeargs+=(
		-DETHSTRATUM=ON
	)
	cmake-utils_src_configure
}
