# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

## BUNDLED-DEPS:
# extern/cuew
# extern/Eigen3
# extern/xdnd
# extern/carve
# extern/glew
# extern/libmv
# extern/clew
# extern/colamd
# extern/lzma
# extern/gtest
# extern/rangetree
# extern/libredcode
# extern/wcwidth
# extern/binreloc
# extern/recastnavigation
# extern/bullet2
# extern/lzo
# extern/libopenjpeg
# extern/libmv/third_party/msinttypes
# extern/libmv/third_party/ceres
# extern/libmv/third_party/gflags
# extern/libmv/third_party/glog

EAPI=5
PYTHON_COMPAT=( python3_4 python3_5 )
# python3_5 need patch 
# https://github.com/thankjura/overlay/blob/5705fb755d4ccecc3b885d863138dcc2d922c92c/dev-lang/python/files/3.5-pyatomicfix.patch

inherit multilib fdo-mime gnome2-utils cmake-utils eutils python-single-r1 versionator flag-o-matic toolchain-funcs pax-utils check-reqs

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"
SRC_URI="http://download.blender.org/source/${P}.tar.gz"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"
IUSE_MODIFIERS="+fluid +smoke +boolean +remesh +oceansim +decimate"
IUSE_GPU="+opengl +cuda -sm_20 -sm_21 -sm_30 -sm_35 -sm_50 -sm_51"
IUSE="${IUSE_MODIFIERS} ${IUSE_GPU} +boost +bullet colorio cycles +dds debug doc +elbeem ffmpeg fftw +game-engine jack jpeg2k libav ndof nls openal openimageio +opennl openmp +openexr player redcode sdl sndfile cpu_flags_x86_sse cpu_flags_x86_sse2 tiff c++0x opensubdiv"

LANGS="en ar bg ca cs de el es es_ES fa fi fr he hr hu id it ja ky ne nl pl pt pt_BR ru sr sr@latin sv tr uk zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE+=" linguas_${X}"
	REQUIRED_USE+=" linguas_${X}? ( nls )"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine opengl )
	game-engine? ( bullet opengl boost )
	redcode? ( jpeg2k ffmpeg )
	cycles? ( boost openexr tiff )
	nls? ( boost )"

RDEPEND="${PYTHON_DEPS}
	dev-libs/lzo:2
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=media-libs/freetype-2.0:2
	media-libs/libpng:0
	media-libs/libsamplerate
	sci-libs/ldl
	sys-libs/zlib
	virtual/jpeg:0
	virtual/libintl
	opengl? ( 
		virtual/opengl
		media-libs/glew
		virtual/glu
	)
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXxf86vm
	boost? ( >=dev-libs/boost-1.44[nls?,threads(+)] )
	colorio? ( <=media-libs/opencolorio-1.0.9 )
	cycles? (
		media-libs/openimageio
	)
	ffmpeg? (
		!libav? ( >=media-video/ffmpeg-2.1.4:0=[x264,mp3,encode,theora,jpeg2k?] )
		libav? ( >=media-video/libav-9:0=[x264,mp3,encode,theora,jpeg2k?] )
	)
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg2k? ( media-libs/openjpeg:0 )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openimageio? ( media-libs/openimageio )
	openexr? ( media-libs/ilmbase media-libs/openexr )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	opensubdiv? ( media-libs/opensubdiv )
"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.2.4:3
	doc? (
		app-doc/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx
	)
	nls? ( sys-devel/gettext )"

pkg_pretend() {
	if use openmp && ! tc-has-openmp; then
		eerror "You are using gcc built without 'openmp' USE."
		eerror "Switch CXX to an OpenMP capable compiler."
		die "Need openmp"
	fi

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.68-doxyfile.patch \
		"${FILESDIR}"/${PN}-2.68-fix-install-rules.patch \
		"${FILESDIR}"/${PN}-2.70-sse2.patch \
		
	epatch_user

	# we don't want static glew, but it's scattered across
	# thousand files
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	sed -i \
		-e '/-DGLEW_STATIC/d' \
		$(find . -type f -name "CMakeLists.txt") || die
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
	append-lfs-flags
    local mycmakeargs=""

    #CUDA Kernal Selection
	local CUDA_ARCH=""
	if use cuda; then
		if use sm_20; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_20"
			else
				CUDA_ARCH="sm_20"
			fi
		fi
		if use sm_21; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_21"
			else
				CUDA_ARCH="sm_21"
			fi
		fi
		if use sm_30; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_30"
			else
				CUDA_ARCH="sm_30"
			fi
		fi
		if use sm_35; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_35"
			else
				CUDA_ARCH="sm_35"
			fi
		fi
		if use sm_50; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_50"
			else
				CUDA_ARCH="sm_50"
			fi
		fi
		if use sm_51; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_51"
			else
				CUDA_ARCH="sm_51"
			fi
		fi

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs="${mycmakeargs} -DCYCLES_CUDA_BINARIES_ARCH=${CUDA_ARCH}"
		fi
		mycmakeargs="${mycmakeargs}
		-DWITH_CYCLES_CUDA=ON
		-DWITH_CYCLES_CUDA_BINARIES=ON
		-D
		-DCUDA_INCLUDES=/opt/cuda/include
		-DCUDA_LIBRARIES=/opt/cuda/lib64
		-DCUDA_NVCC=/opt/cuda/bin/nvcc"
	fi

	# WITH_PYTHON_SECURITY
	# WITH_PYTHON_SAFETY
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX=/usr
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DWITH_INSTALL_PORTABLE=OFF
		$(cmake-utils_use_with boost BOOST)
		$(cmake-utils_use_with bullet BULLET)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with c++0x CPP11)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with jack JACK)
		
		$(cmake-utils_use_with boolean MOD_BOOLEAN)
		$(cmake-utils_use_with remesh MOD_REMESH)
		$(cmake-utils_use_with fluid MOD_FLUID)
		$(cmake-utils_use_with oceansim MOD_OCEANSIM)
		$(cmake-utils_use_with decimate MOD_DECIMATE)
		$(cmake-utils_use_with smoke MOD_SMOKE)
		
		$(cmake-utils_use_with openal OPENAL)
		-DWITH_OPENCOLLADA=OFF
		$(cmake-utils_use_with colorio OPENCOLORIO)
		$(cmake-utils_use_with openimageio OPENIMAGEIO)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with opennl OPENNL)
		$(cmake-utils_use_with player PLAYER)
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		$(cmake-utils_use_with cpu_flags_x86_sse RAYOPTIMIZATION)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with cpu_flags_x86_sse2 SSE2)
		$(cmake-utils_use_with opensubdiv OPENSUBDIV)
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_BULLET=OFF
		-DWITH_SYSTEM_EIGEN3=ON
		-DWITH_SYSTEM_LZO=ON"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile || die
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "blender failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."
	fi
}

src_test() { :; }

src_install() {
	local i

	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	if use doc; then
		docinto "API/python"
		dohtml -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/*

		docinto "API/blender"
		dohtml -r "${CMAKE_USE_DIR}"/doc/doxygen/html/*
	fi

	# fucked up cmake will relink binary for no reason
	emake -C "${CMAKE_BUILD_DIR}" DESTDIR="${D}" install/fast

	# fix doc installdir
	dohtml "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender || die

	python_fix_shebang "${ED%/}"/usr/bin/blender-thumbnailer.py
	python_optimize "${ED%/}"/usr/share/blender/${PV}/scripts
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}
