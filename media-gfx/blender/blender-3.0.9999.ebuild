# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{7,8,9} )

inherit check-reqs cmake-utils python-single-r1 pax-utils flag-o-matic git-r3 l10n xdg

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"

EGIT_REPO_URI="https://git.blender.org/blender.git"
EGIT_BRANCH="master"
EGIT_OVERRIDE_BRANCH_BLENDER_ADDONS="master"
EGIT_OVERRIDE_COMMIT_BLENDER_ADDONS="master"

EGIT_OVERRIDE_BRANCH_BLENDER_ADDONS_CONTRIB="master"
EGIT_OVERRIDE_COMMIT_BLENDER_ADDONS_CONTRIB="master"

EGIT_OVERRIDE_BRANCH_BLENDER_TRANSLATIONS="master"
EGIT_OVERRIDE_COMMIT_BLENDER_TRANSLATIONS="master"

EGIT_OVERRIDE_BRANCH_BLENDER_DEV_TOOLS="master"
EGIT_OVERRIDE_COMMIT_BLENDER_DEV_TOOLS="master"

LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64"
SLOT="0"
MY_PV="$(ver_cut 1-2)"

IUSE_GPU="+optix cuda opencl -sm_30 -sm_35 -sm_50 -sm_52 -sm_61 -sm_70 -sm_75 -sm_86"
IUSE="+bullet +dds +elbeem +openexr +system-python +system-numpy +tbb \
	abi6-compat +abi7-compat alembic collada +color-management +oidn +cycles \
	debug doc ffmpeg fftw headless jack jemalloc jpeg2k llvm \
	man ndof nls openal openimageio openmp opensubdiv embree freestyle \
	+openvdb osl sdl sndfile standalone test tiff valgrind wayland ${IUSE_GPU}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	alembic? ( openexr )
	cuda? ( cycles )
	cycles? ( openexr tiff openimageio )
	elbeem? ( tbb )
	opencl? ( cycles )
	openvdb? (
		^^ ( abi6-compat abi7-compat )
		tbb
	)
	osl? ( cycles llvm )
	oidn? ( cycles )
	embree? ( cycles )
	standalone? ( cycles )"

RDEPEND="${PYTHON_DEPS}
	dev-libs/boost:=[nls?,threads(+)]
	dev-libs/lzo:2=
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
	media-libs/freetype:=
	media-libs/glew:*
	media-libs/libpng:=
	media-libs/libsamplerate
	sys-libs/zlib:=
	virtual/glu
	virtual/jpeg
	virtual/libintl
	virtual/opengl
	alembic? ( >=media-gfx/alembic-1.7.12[boost(+),hdf(+)] )
	collada? ( >=media-libs/opencollada-1.6.68 )
	color-management? ( media-libs/opencolorio )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	optix? ( dev-libs/optix )
	ffmpeg? ( media-video/ffmpeg:=[x264,mp3,encode,theora,jpeg2k?] )
	fftw? ( sci-libs/fftw:3.0= )
	!headless? (
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXxf86vm
	)
	jack? ( virtual/jack )
	jemalloc? ( dev-libs/jemalloc:= )
	jpeg2k? ( media-libs/openjpeg:2= )
	llvm? ( sys-devel/llvm:= )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( media-libs/openal )
	opencl? ( virtual/opencl )
	openimageio? ( media-libs/openimageio )
	openexr? (
		media-libs/ilmbase:=
		media-libs/openexr:=
	)
	opensubdiv? ( >=media-libs/opensubdiv-3.4.0[cuda=,opencl=] )
	openvdb? (
		~media-gfx/openvdb-7.0.0[abi6-compat(-)?,abi7-compat(-)?]
		dev-libs/c-blosc:=
	)
	osl? ( media-libs/osl )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tbb? ( dev-cpp/tbb )
	tiff? ( media-libs/tiff )
	valgrind? ( dev-util/valgrind )
	oidn? ( media-libs/oidn )
	embree? ( media-libs/embree )
"

DEPEND="${RDEPEND}
	dev-cpp/eigen:=
"

BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen[dot]
		dev-python/sphinx[latex]
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	nls? ( sys-devel/gettext )
"

CMAKE_BUILD_TYPE="Release"

blender_check_requirements() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_pretend() {
	blender_check_requirements
}

pkg_setup() {
	blender_check_requirements
	python-single-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare

	# we don't want static glew, but it's scattered across
	# multiple files that differ from version to version
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	local file
	while IFS="" read -d $'\0' -r file ; do
		sed -i -e '/-DGLEW_STATIC/d' "${file}" || die
	done < <(find . -type f -name "CMakeLists.txt")

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
		-i doc/doxygen/Doxyfile || die

	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
		-i doc/doxygen/Doxyfile || die

	# we don't want static glew, but it's scattered across
	# multiple files that differ from version to version
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	local file
	while IFS="" read -d $'\0' -r file ; do
		sed -i -e '/-DGLEW_STATIC/d' "${file}" || die
	done < <(find . -type f -name "CMakeLists.txt")

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" -i doc/doxygen/Doxyfile || die
	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"

	# cleanup addons
	for a in $(ls "${S}"/release/scripts/addons_contrib/); do
		if [[ -d "${S}"/release/scripts/addons/${a} || -f "${S}"/release/scripts/addons/${a} ]]; then
			ewarn "Duplicate ${a}, removing"
			rm -r "${S}"/release/scripts/addons_contrib/${a}
		fi
	done
}

src_configure() {
	append-flags -funsigned-char -fno-strict-aliasing
	append-lfs-flags

	if use openvdb; then
		local version
		if use abi6-compat; then
			version=6;
		elif use abi7-compat; then
			version=7;
		else
			die "Openvdb abi version not compatible"
		fi
		append-cppflags -DOPENVDB_ABI_VERSION_NUMBER=${version}
	fi

	local mycmakeargs=""
	#CUDA Kernel Selection
	local CUDA_ARCH=""
	if use cuda; then
		for CA in 30 35 50 52 61 70 75 86; do
			if use sm_${CA}; then
				if [[ -n "${CUDA_ARCH}" ]] ; then
					CUDA_ARCH="${CUDA_ARCH};sm_${CA}"
				else
					CUDA_ARCH="sm_${CA}"
				fi
			fi
		done

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs+=(
				-DCYCLES_CUDA_BINARIES_ARCH=${CUDA_ARCH}
			)
		fi

		mycmakeargs+=(
			-DWITH_CYCLES_CUDA=ON
			-DWITH_CYCLES_CUDA_BINARIES=ON
			-DCUDA_TOOLKIT_ROOT_DIR=/opt/cuda
			-DCUDA_NVCC_EXECUddDABLE=/opt/cuda/bin/nvcc
		)
	fi

	if use optix; then
		mycmakeargs+=(
			-DOPTIX_ROOT_DIR=/opt/optix
			-DOPTIX_INCLUDE_DIR=/opt/optix/include
			-DWITH_CYCLES_DEVICE_OPTIX=ON
		)
	else
		mycmakeargs+=(
			-DWITH_CYCLES_DEVICE_OPTIX=OFF
		)
	fi

	mycmakeargs+=(
		-DBUILD_SHARED_LIBS=OFF
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DWITH_ALEMBIC=$(usex alembic)
		-DWITH_ASSERT_ABORT=$(usex debug)
		-DWITH_BOOST=ON
		-DWITH_BULLET=$(usex bullet)
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg)
		-DWITH_CODEC_SNDFILE=$(usex sndfile)
		-DWITH_CXX_GUARDEDALLOC=$(usex debug)
		-DWITH_CYCLES_DEVICE_CUDA=$(usex cuda TRUE FALSE)
		-DWITH_CYCLES=$(usex cycles)
		-DWITH_CYCLES_DEVICE_OPENCL=$(usex opencl)
		-DWITH_CYCLES_EMBREE=$(usex embree)
		-DWITH_CYCLES_STANDALONE=$(usex standalone)
		-DWITH_CYCLES_STANDALONE_GUI=$(usex standalone)
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_DOC_MANPAGE=$(usex man)
		-DWITH_FFTW3=$(usex fftw)
		-DWITH_GTESTS=$(usex test)
		-DWITH_HEADLESS=$(usex headless)
		-DWITH_INSTALL_PORTABLE=OFF
		-DWITH_FREESTYLE=$(usex freestyle)
		-DWITH_IMAGE_DDS=$(usex dds)
		-DWITH_IMAGE_OPENEXR=$(usex openexr)
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k)
		-DWITH_IMAGE_TIFF=$(usex tiff)
		-DWITH_INPUT_NDOF=$(usex ndof)
		-DWITH_INTERNATIONAL=$(usex nls)
		-DWITH_JACK=$(usex jack)
		-DWITH_LLVM=$(usex llvm)
		-DWITH_MEM_JEMALLOC=$(usex jemalloc)
		-DWITH_MEM_VALGRIND=$(usex valgrind)
		-DWITH_MOD_FLUID=$(usex elbeem)
		-DWITH_MOD_OCEANSIM=$(usex fftw)
		-DWITH_OPENAL=$(usex openal)
		-DWITH_OPENCOLLADA=$(usex collada)
		-DWITH_OPENCOLORIO=$(usex color-management)
		-DWITH_OPENIMAGEIO=$(usex openimageio)
		-DWITH_OPENMP=$(usex openmp)
		-DWITH_OPENSUBDIV=$(usex opensubdiv)
		-DWITH_OPENVDB=$(usex openvdb)
		-DWITH_OPENVDB_BLOSC=$(usex openvdb)
		-DWITH_PYTHON_INSTALL=$(usex system-python OFF ON)
		-DWITH_PYTHON_INSTALL_NUMPY=$(usex system-numpy OFF ON)
		-DWITH_SDL=$(usex sdl)
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_EIGEN3=ON
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_LZO=ON
		-DWITH_TBB=$(usex tbb)
		-DWITH_X11=$(usex !headless)
		-DWITH_GHOST_WAYLAND=$(usex wayland)
	)

	if use oidn; then
		mycmakeargs+=(
			-DOPENIMAGEDENOISE_COMMON_LIBRARY=/usr/lib64/
			-DOPENIMAGEDENOISE_MKLDNN_LIBRARY=/usr/lib64/
		)
	fi

	cmake-utils_src_configure
}

cmake-utils_src_configure() {
	_cmake_check_build_dir || die
	pushd "${BUILD_DIR}" > /dev/null || die
	"${CMAKE_BINARY}" -G "$(_cmake_generator_to_use)" -DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr" "${mycmakeargs[@]}" "${CMAKE_USE_DIR}" || die "cmake failed"
	popd > /dev/null || die
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile
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
	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	if use doc; then
		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/.

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/.
	fi

	cmake-utils_src_install

	# fix doc installdir
	docinto "html"
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender || die

	python_fix_shebang "${ED%/}/usr/bin/blender-thumbnailer.py"
	python_optimize "${ED%/}/usr/share/blender/${MY_PV}/scripts"
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update

	ewarn ""
	ewarn "You may want to remove the following directory."
	ewarn "~/.config/${PN}/${MY_PV}/cache/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn ""
}
