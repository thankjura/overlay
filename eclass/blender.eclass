# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PYTHON_DEPEND="3:3.2"
EAPI=3

inherit eutils python subversion versionator flag-o-matic toolchain-funcs

IUSE="+game-engine player +elbeem +openexr ffmpeg jpeg2k openal openmp \
   +dds debug fftw jack apidoc sndfile lcms tweak-mode sdl sse \
   redcode +zlib iconv contrib collada 3dmouse"

# not complete/working features
#IUSE="verse test"

LANGS="en ar bg ca cs de el es fi fr hr it ja ko nl pl pt_BR ro ru sr sv uk zh_CN"
for X in ${LANGS} ; do
   IUSE="${IUSE} linguas_${X}"
done

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"

LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~amd64-fbsd ~ppc ~ppc64 ~x86 ~x86-fbsd"

RDEPEND="virtual/jpeg
   media-libs/libpng
   x11-libs/libXi
   x11-libs/libX11
   media-libs/tiff
   media-libs/libsamplerate
   virtual/opengl
   >=media-libs/freetype-2.0
   virtual/libintl
   media-libs/glew
   dev-cpp/eigen:2
   >=sci-physics/bullet-2.76
   iconv? ( virtual/libiconv )
   zlib? ( sys-libs/zlib )
   sdl? ( media-libs/libsdl[audio,joystick] )
   openexr? ( media-libs/openexr )
   ffmpeg? (
       >=virtual/ffmpeg-0.6.90[x264,mp3,encode,theora]
       jpeg2k? ( >=virtual/ffmpeg-0.6.90[x264,mp3,encode,theora,jpeg2k] )
   )
   openal? ( >=media-libs/openal-1.6.372 )
   fftw? ( sci-libs/fftw:3.0 )
   jack? ( media-sound/jack-audio-connection-kit )
   sndfile? ( media-libs/libsndfile )
   lcms? ( media-libs/lcms )
   collada? ( media-libs/opencollada )
   3dmouse? ( app-misc/libspnav )"

DEPEND=">=dev-util/scons-0.98
   apidoc? (
      dev-python/sphinx
      >=app-doc/doxygen-1.5.7[-nodot]
   )
   x11-base/xorg-server
   ${RDEPEND}"

# configure internationalization only if LINGUAS have more
# languages than 'en', otherwise must be disabled
if [[ ${LINGUAS} != "en" && -n ${LINGUAS} ]]; then
   DEPEND="${DEPEND}
      sys-devel/gettext"
fi

S="${WORKDIR}/${PN}"

blend_with() {
   local UWORD="$2"
   [ -z "${UWORD}" ] && UWORD="$1"
   if useq $1; then
      echo "WITH_BF_${UWORD}=1" | tr '[:lower:]' '[:upper:]' \
         >> "${S}"/user-config.py
   else
      echo "WITH_BF_${UWORD}=0" | tr '[:lower:]' '[:upper:]' \
         >> "${S}"/user-config.py
   fi
}

src_unpack(){
   subversion_fetch
   if use contrib; then
      S="${S}"/release/scripts/addons_contrib subversion_fetch \
      "https://svn.blender.org/svnroot/bf-extensions/contrib/py/scripts/addons/"
   fi
}

pkg_setup() {
   enable_openmp=0
   if use openmp; then
      if tc-has-openmp; then
         enable_openmp=1
      else
         ewarn "You are using gcc built without 'openmp' USE."
         ewarn "Switch CXX to an OpenMP capable compiler."
         die "Need openmp"
      fi
   fi
   python_set_active_version 3
}

src_prepare() {
#    epatch "${FILESDIR}"/${PN}-desktop.patch

cat <<-EOF>> release/freedesktop/blender-${SLOT}.desktop
[Desktop Entry]
Name=Blender-${SLOT}
GenericName=3D modeller
GenericName[es]=modelador 3D
GenericName[de]=3D Modellierer
GenericName[ru]=Редактор 3D-моделей
Comment=3D modeling, animation, rendering and post-production
Comment[es]=modelado 3D, animación, renderizado y post-producción
Exec=blender-${SLOT} %f
Icon=blender-${SLOT}.svg
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;
EOF

   epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-doxygen.patch

   # TODO: write a proper Makefile to replace the borked bmake script
   epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-bmake.patch

   # OpenJPEG
   einfo "Removing bundled OpenJPEG ..."
   rm -r extern/libopenjpeg

   # Glew
   einfo "Removing bundled Glew ..."
   rm -r extern/glew
   epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-glew.patch

   # binreloc
#  einfo "Removing bundled binreloc ..."
#  rm -r extern/binreloc
#  epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-binreloc.patch

   # Eigen2
   einfo "Removing bundled Eigen2 ..."
   rm -r extern/Eigen2
   epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-eigen.patch

   # Bullet
#  einfo "Removing bundled Bullet2 ..."
#  rm -r extern/bullet2
#  epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-bullet.patch

   #Since Linus Torvalds says that linux-3.0 is just about
   #renameing see (https://lkml.org/lkml/2011/5/29/204) we
   #can still use the linux2 config file
   if [[ $(uname -r | sed "s/\(^[0-9]\).*/\1/") = 3 ]]
   then
      epatch "${FILESDIR}"/${PN}-${PATCH_SLOT}-linux3.patch
   fi
}

src_configure() {
   # add system openjpeg into Scons build options.
cat <<-EOF>> "${S}"/user-config.py
BF_OPENJPEG="/usr"
BF_OPENJPEG_INC="/usr/include"
BF_OPENJPEG_LIB="openjpeg"
EOF
   # FIX: littlecms includes path aren't specified
   if use lcms; then
cat <<-EOF>> "${S}"/user-config.py
BF_LCMS_INC="/usr/include/"
BF_LCMS_LIB="lcms"
BF_LCMS_LIBPATH="/usr/lib/"
EOF
   fi

   # add system sci-physic/bullet into Scons build options.
#  cat <<-EOF>> "${S}"/user-config.py
#     WITH_BF_BULLET=1
#     BF_BULLET="/usr/include"
#     BF_BULLET_INC="/usr/include /usr/include/BulletCollision /usr/include/BulletDynamics /usr/include/LinearMath /usr/include/BulletSoftBody"
#     BF_BULLET_LIB="BulletSoftBody BulletDynamics BulletCollision LinearMath"
#  EOF

   #add iconv into Scons build options.
   if use !elibc_glibc && use !elibc_uclibc && use iconv; then
cat <<-EOF>> "${S}"/user-config.py
WITH_BF_ICONV=1
BF_ICONV="/usr"
EOF
   fi

   # configure internationalization only if LINGUAS have more
   # languages than 'en', otherwise must be disabled
   [[ -z ${LINGUAS} ]] || [[ ${LINGUAS} == "en" ]] && echo "WITH_BF_INTERNATIONAL=0" >> "${S}"/user-config.py

   # configure Elbeem fluid system
   use elbeem || echo "BF_NO_ELBEEM=1" >> "${S}"/user-config.py

   # configure Tweak Mode
   use tweak-mode && echo "BF_TWEAK_MODE=1" >> "${S}"/user-config.py

   # FIX: Game Engine module needs to be active to build the Blender Player
   if ! use game-engine && use player; then
      elog "Forcing Game Engine [+game-engine] as required by Blender Player [+player]"
      echo "WITH_BF_GAMEENGINE=1" >> "${S}"/user-config.py
   else
      blend_with game-engine gameengine
   fi

   # set CFLAGS used in /etc/make.conf correctly
   echo "CFLAGS=[`for i in ${CFLAGS[@]}; do printf "%s \'$i"\',; done`] " \
      | sed -e "s:,]: ]:" >> "${S}"/user-config.py

   # set CXXFLAGS used in /etc/make.conf correctly
   local FILTERED_CXXFLAGS="`for i in ${CXXFLAGS[@]}; do printf "%s \'$i"\',; done`"
   echo "CXXFLAGS=[${FILTERED_CXXFLAGS}]" | sed -e "s:,]: ]:" >> "${S}"/user-config.py
   echo "BGE_CXXFLAGS=[${FILTERED_CXXFLAGS}]" | sed -e "s:,]: ]:" >> "${S}"/user-config.py

   # reset general options passed to the C/C++ compilers (useless hardcoded flags)
   # FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
   # shadows, see bug #276338 for reference
   echo "CCFLAGS= ['-funsigned-char', '-D_LARGEFILE_SOURCE', '-D_FILE_OFFSET_BITS=64']" >> "${S}"/user-config.py

   # set LDFLAGS used in /etc/make.conf correctly
   local FILTERED_LDFLAGS="`for i in ${LDFLAGS[@]}; do printf "%s \'$i"\',; done`"
   echo "LINKFLAGS=[${FILTERED_LDFLAGS}]" | sed -e "s:,]: ]:" >> "${S}"/user-config.py
   echo "PLATFORM_LINKFLAGS=[${FILTERED_LDFLAGS}]" | sed -e "s:,]: ]:" >> "${S}"/user-config.py

   # reset REL_* variables (useless hardcoded flags)
cat <<-EOF>> "${S}"/user-config.py
REL_CFLAGS=[]
REL_CXXFLAGS=[]
REL_CCFLAGS=[]
EOF

   # reset warning flags (useless for NON blender developers)
cat <<-EOF>> "${S}"/user-config.py
C_WARN  =[ '-w', '-g0' ]
CC_WARN =[ '-w', '-g0' ]
CXX_WARN=[ '-w', '-g0' ]
EOF

   # detecting -j value from MAKEOPTS
   local NUMJOBS="$( echo "${MAKEOPTS}" | sed -ne 's,.*-j\([[:digit:]]\+\).*,\1,p' )"
   [[ -z "${NUMJOBS}" ]] && NUMJOBS=1 # resetting to -j1 for empty MAKEOPTS

   # generic settings which differ from the defaults from linux2-config.py
cat <<-EOF>> "${S}"/user-config.py
BF_OPENGL_LIB='GL GLU X11 Xi GLEW'
BF_INSTALLDIR="../install"
WITHOUT_BF_PYTHON_INSTALL=1
BF_PYTHON="/usr"
BF_PYTHON_VERSION="3.2"
BF_PYTHON_ABI_FLAGS=""
BF_BUILDINFO=0
BF_QUIET=1
BF_NUMJOBS=${NUMJOBS}
BF_LINE_OVERWRITE=0
WITH_BF_FHS=1
WITH_BF_BINRELOC=0
WITH_BF_STATICOPENGL=0
WITH_BF_OPENMP=${enable_openmp}
EOF

   if use collada
   then
   cat <<-EOF>> "${S}"/user-config.py
      BF_OPENCOLLADA_INC='/usr/include/opencollada'
      BF_OPENCOLLADA_LIBPATH='/usr/lib/opencollada'
EOF
   fi

   # configure WITH_BF* Scons build options
   for arg in \
      'sdl' \
      'apidoc docs' \
      'lcms' \
      'jack' \
      'sndfile' \
      'openexr' \
      'dds' \
      'fftw fftw3' \
      'jpeg2k openjpeg' \
      'openal'\
      'ffmpeg' \
      'ffmpeg ogg' \
      'player' \
      'collada' \
      'sse rayoptimization' \
      'redcode' \
      'zlib' \
      'verse' \
      '3dmouse' ; do
      blend_with ${arg}
   done

   # enable debugging/testing support
   use debug && echo "BF_DEBUG=1" >> "${S}"/user-config.py
   use test && echo "BF_UNIT_TEST=1" >> "${S}"/user-config.py
}

src_compile() {
   scons || die \
      '!!! Please add "${S}/scons.config" when filing bugs reports \
      to bugs.gentoo.org'

#  einfo "Building plugins ..."
#  cd "${WORKDIR}"/install/2.57/plugins/ \
#     || die "dir ${WORKDIR}/install/plugins/ do not exist"
#  chmod 755 bmake

   # FIX: plugins are built without respecting user's LDFLAGS
#  emake \
#     CFLAGS="${CFLAGS} -fPIC" \
#     LDFLAGS="$(raw-ldflags) -Bshareable" \
#     > /dev/null \
#     || die "plugins compilation failed"
}

src_install() {
   # creating binary wrapper
   cat <<-EOF>> "${WORKDIR}/install/blender-${SLOT}"
#!/bin/sh

# stop this script if the local blender path is a symlink
if [ -L \${HOME}/.blender ]; then
   echo "Detected a symbolic link for \${HOME}/.blender"
   echo "Sorry, to avoid dangerous situations, the Blender binary can"
   echo "not be started until you have removed the symbolic link:"
   echo "  # rm -i \${HOME}/.blender"
   exit 1
fi

export BLENDER_SYSTEM_SCRIPTS="/usr/share/blender/${SLOT}/scripts"
export BLENDER_SYSTEM_DATAFILES="/usr/share/blender/${SLOT}/datafiles"
exec /usr/bin/blender-bin-${SLOT} \$*
EOF

   # install binaries
   exeinto /usr/bin/
   mv "${WORKDIR}/install/blender" "${WORKDIR}/install/blender-bin-${SLOT}"
   doexe "${WORKDIR}/install/blender-bin-${SLOT}"
   doexe "${WORKDIR}/install/blender-${SLOT}"
   if use player; then
      mv "${WORKDIR}/install/blenderplayer" \
         "${WORKDIR}/install/blenderplayer-${SLOT}"
      doexe "${WORKDIR}/install/blenderplayer-${SLOT}"
   fi


   # install desktop file
   insinto /usr/share/pixmaps
   cp release/freedesktop/icons/scalable/apps/blender.svg \
      release/freedesktop/icons/scalable/apps/blender-${SLOT}.svg
   doins release/freedesktop/icons/scalable/apps/blender-${SLOT}.svg
   insinto /usr/share/applications
   doins release/freedesktop/blender-${SLOT}.desktop

   # install docs
#  use doc && dodoc release/text/BlenderQuickStart.pdf
   if use apidoc; then

      einfo "Generating (BGE) Blender Game Engine API docs ..."
      docinto "API/BGE_API"
      dohtml -r "${WORKDIR}"/blender/doc/*

      einfo "Generating Blender C/C++ API docs ..."
      pushd "${WORKDIR}"/blender/doc/doxygen > /dev/null
         doxygen -u Doxyfile
         doxygen || die "doxygen failed to build API docs."
         docinto "API/blender"
         dohtml -r html/*
      popd > /dev/null
   fi

   # final cleanup
   rm -r "${WORKDIR}"/install/{Python-license.txt,icons,GPL-license.txt,copyright.txt}

   # installing blender
   insinto /usr/share/${PN}/${SLOT}
   doins -r "${WORKDIR}"/install/${DIR_SLOT}/*
}

#pkg_preinst() {
#  if [ -h "${ROOT}/usr/$(get_libdir)/blender/plugins/include" ];
#  then
#     rm -r "${ROOT}"/usr/$(get_libdir)/blender/plugins/include
#  fi
#}

pkg_postinst() {
   echo
   elog "Blender uses python integration. As such, may have some"
   elog "inherit risks with running unknown python scripting."
   elog
   elog "It is recommended to change your blender temp directory"
   elog "from /tmp to /home/user/tmp or another tmp file under your"
   elog "home directory. This can be done by starting blender, then"
   elog "dragging the main menu down do display all paths."
   elog
   elog "Blender has its own internal rendering engine but you"
   elog "can export to external renderers for image computation"
   elog "like: YafRay[1], sunflow[2], PovRay[3] and luxrender[4]"
   elog
   elog "If you need one of them just emerge it:"
   elog "  [1] emerge -av media-gfx/yafray"
   elog "  [2] emerge -av media-gfx/sunflow"
   elog "  [3] emerge -av media-gfx/povray"
   elog "  [4] emerge -av media-gfx/luxrender"
   elog
   elog "When setting the Blender paths with the User Preferences"
   elog "dialog box, remember to NOT declare your home's paths as:"
   elog "~/.blender, but as: /home/user/.blender; in other words,"
   elog "DO NOT USE the tilde inside the paths, as Blender is not"
   elog "able to handle it, ignoring your customizations."
}
