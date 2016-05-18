# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

{
	min_qt_ver="5.5.1"
	min_qt_patch_date="20160510"
}

GH_REPO='telegramdesktop/tdesktop'
GH_TAG="v${PV}"

inherit flag-o-matic check-reqs fdo-mime eutils qmake-utils github

DESCRIPTION='Official cross-platorm desktop client for Telegram'
HOMEPAGE='https://desktop.telegram.org/'
LICENSE='GPL-3' # with OpenSSL exception

SLOT='0'

KEYWORDS='~amd64 ~arm ~x86'

RESTRICT+=' test'

RDEPEND=(
	'dev-libs/libappindicator:3'
	'>=media-libs/openal-1.17.2'	# Telegram requires shiny new versions
	'sys-libs/zlib[minizip]'
	'virtual/ffmpeg[opus]'
)
DEPEND=( "${RDEPEND[@]}"
	">=dev-qt/qt-telegram-static-${min_qt_ver}_p${min_qt_patch_date}"
	'virtual/pkgconfig'
)
DEPEND="${DEPEND[*]}"
RDEPEND="${RDEPEND[*]}"

PLOCALES='de es it ko nl pt_BR'
inherit l10n

CHECKREQS_DISK_BUILD='800M'

tg_dir="${S}/Telegram"
tg_pro="${tg_dir}/Telegram.pro"

# override qt5 path for use with eqmake5
qt5_get_bindir() { echo "${QT5_PREFIX}/bin" ; }

src_prepare-locales() {
	l10n_find_plocales_changes 'Resources/langs' 'lang_' '.strings'
	rm_loc() {
		rm -v -f "Resources/langs/lang_${1}.strings" || die
		sed -e "\|lang_${1}.strings|d" \
			-i -- "${tg_pro}" 'Resources/telegram.qrc' || die
	}
	l10n_for_each_disabled_locale_do rm_loc
}

src_prepare-delete_and_modify() {
	local args

	## change references to static Qt dir
	args=(
		 -e "s#/usr/local[^ ]*/Qt[^ ]*/((include|plugins)/[^ ]*)#${QT5_PREFIX}/\1#g"
		 -e "s|[^ ]*Libraries/QtStatic/qtbase/([^ \"\\]*)|${QT5_PREFIX}/\1|g"
	)
	sed -r "${args[@]}" \
		-i -- *.pro || die
	sed -r -e 's|".*src/gui/text/qfontengine_p.h"|<private/qfontengine_p.h>|' \
		-i -- 'SourceFiles/ui/text'/{text.h,text_block.h} || die

	## patch "${tg_pro}"
	args=(
		# delete any references to local includes/libs
		-e 's|[^ ]*/usr/local/[^ \\]* *(\\?)| \1|'
		# delete any hardcoded includes
		-e 's|(.*INCLUDEPATH *\+= *"/usr.*)|#hardcoded includes#\1|'
		# delete any hardcoded libs
		-e 's|(.*LIBS *\+= *-l.*)|#hardcoded libs#\1|'
		# delete refs to bundled Google Breakpad
		-e 's|(.*breakpad/src.*)|#Google Breakpad#\1|'
		# delete refs to bundled minizip, Gentoo uses it's own patched version
		-e 's|(.*minizip.*)|#minizip#\1|'
		# delete CUSTOM_API_ID defines, use default ID
		-e 's|(.*CUSTOM_API_ID.*)|#CUSTOM_API_ID#\1|'
		# remove hardcoded flags
		-e 's|(.*QMAKE_[A-Z]*FLAGS.*)|#hardcoded flags#\1|'
		# use release versions
		-e 's:Debug(Style|Lang):Release\1:g'
		-e 's|/Debug|/Release|g'
		# fix Qt version
		-e "s|5.6.0|${qt_ver}|g"
	)
	sed -r "${args[@]}" \
		-i -- "${tg_pro}" || die

	## nuke libunity references
	args=(
		# ifs cannot be deleted, so replace them with 0
		-e 's|if *\( *_psUnityLauncherEntry *\)|if(0)|'
		# this is probably not needed, but anyway
		-e 's|noTryUnity *= *false,|noTryUnity = true,|'
		# delete includes
		-e 's|(.*unity\.h.*)|// \1|'
		# delete various refs
		-e 's|(.*f_unity*)|// \1|'
		-e 's|(.*ps_unity_*)|// \1|'
		-e 's|(.*UnityLauncher*)|// \1|'
	)
	sed -r "${args[@]}" \
		-i -- 'SourceFiles/pspecific_linux.cpp' || die
}

src_prepare-appends() {
	# make sure there is at least one empty line at the end before adding anything
	echo >> "${tg_pro}"

	printf '%s\n\n' '# --- EBUILD APPENDS BELOW ---' >> "${tg_pro}" || die

	## add corrected dependencies back
	local deps=( 'appindicator3-0.1' 'minizip')
	local libs=( "${deps[@]}"
		'lib'{avcodec,avformat,avutil,swresample,swscale}
		'openal' 'openssl' 'zlib' )
	local includes=( "${deps[@]}" ) # dee-1.0 # TODO

	my_do() {
		local x var="$1" flags="$2" ; shift 2
		for x in "${@}" ; do
			printf '%s += ' "${var}" >>"${tg_pro}" || die
			pkg-config "${flags}" "${x}" | tr -d '\n' >>"${tg_pro}"
			assert
			echo " # $x" >>"${tg_pro}" || die
		done
	}

	my_do QMAKE_CXXFLAGS	--cflags-only-I	"${includes[@]}"
	my_do LIBS				--libs			"${libs[@]}"
}

src_prepare() {
	eapply_user

	cd "${tg_dir}" || die

	rm -rf *.*proj* || die	# delete Xcode/MSVS files

	local p='dev-qt/qt-telegram-static'
	local best_ver="$(best_version "${p}" | sed "s|.*${p}-||")"
	echo
	elog "${P} is going to be linked against '${p}-${best_ver}'"
	echo
	best_ver="${best_ver%%-*}" # strip revision
	qt_ver="${best_ver%%_p*}"
	qt_patch_date="${best_ver##*_p}"

	declare -g QT5_PREFIX="${EPREFIX}/opt/qt-telegram-static/${qt_ver}/${qt_patch_date}"
	readonly QT5_PREFIX
	[ -d "${QT5_PREFIX}" ] || die "QT5_PREFIX dir doesn't exist: '${QT5_PREFIX}'"

	src_prepare-locales
	src_prepare-delete_and_modify
	src_prepare-appends
}

src_configure() {
	## add flags previously stripped from "${tg_pro}"
	append-cxxflags '-fno-strict-aliasing'
	# `append-ldflags '-rdynamic'` was stripped because it's used probably only for GoogleBreakpad
	# which is not supported anyway

	# care a little less about the unholy mess
	append-cxxflags '-Wno-unused-'{function,parameter,variable,but-set-variable}
	append-cxxflags '-Wno-switch'

	# prefer patched qt
	export PATH="$(qt5_get_bindir):${PATH}"

	(	# disable updater
		echo 'DEFINES += TDESKTOP_DISABLE_AUTOUPDATE'

		# disable registering `tg://` scheme from within the app
		echo 'DEFINES += TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME'

		# https://github.com/telegramdesktop/tdesktop/commit/0b2bcbc3e93a7fe62889abc66cc5726313170be7
		# echo 'DEFINES += TDESKTOP_DISABLE_NETWORK_PROXY'

		# disable google-breakpad support
		echo 'DEFINES += TDESKTOP_DISABLE_CRASH_REPORTS'
	) >>"${tg_pro}" || die
}

src_compile() {
	local d mode='release' module

	for module in style numbers ; do	# order of modules matters
		d="${S}/Linux/obj/codegen_${module}/${mode^}"
		mkdir -v -p "${d}" && cd "${d}" || die

		elog "Building: ${PWD/${S}\/}"
		eqmake5 CONFIG+="${mode}" \
			"${tg_dir}/build/qmake/codegen_${module}/codegen_${module}.pro"
		emake
	done

	for module in Lang ; do		# order of modules matters
		d="${S}/Linux/${mode^}Intermediate${module}"
		mkdir -v -p "${d}" && cd "${d}" || die

		elog "Building: ${PWD/${S}\/}"
		eqmake5 CONFIG+="${mode}" "${tg_dir}/Meta${module}.pro"
		emake
	done

	d="${S}/Linux/${mode^}Intermediate"
	mkdir -v -p "${d}" && cd "${d}" || die

	elog "Preparing the main build ..."
	# this qmake will fail to find "${tg_dir}/GeneratedFiles/*", but it's required for ...
	eqmake5 CONFIG+="${mode}" "${tg_pro}"
	# ... this make, which will generate those files
	local targets=( $( awk '/^PRE_TARGETDEPS *\+=/ { $1=$2=""; print }' "${tg_pro}" ) )
	[ ${#targets[@]} -eq 0 ] && die
	emake ${targets[@]}

	# now we have everything we need, so let's begin!
	elog "Building Telegram ..."
	eqmake5 CONFIG+="${mode}" "${tg_pro}"
	emake
}

src_install() {
	newbin "${S}/Linux/Release/Telegram" "${PN}"

	local s
	for s in 16 32 48 64 128 256 512 ; do
		newicon -s ${s} "${tg_dir}/Resources/art/icon${s}.png" "${PN}.png"
	done

	local make_desktop_entry_args
	make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} %u"	# exec
		"${PN^}"	# name
		"${PN}"		# icon
		'Network;InstantMessaging;Chat'	# categories
	)
	make_desktop_entry_extras=(
		'MimeType=x-scheme-handler/tg;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	einstalldocs
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
