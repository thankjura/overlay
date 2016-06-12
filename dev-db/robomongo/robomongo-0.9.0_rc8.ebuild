# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils toolchain-funcs

DESCRIPTION="Robomongo — is a shell-centric crossplatform MongoDB management tool."

ROBOSHELL_COMMIT="798c6c93c10f5ff1cb4f4ba9d0488ecb756a8685"

MY_PV=${PV/_/-}
HOMEPAGE="http://www.robomongo.org/"
SRC_URI="https://github.com/paralect/robomongo/archive/v${MY_PV}.tar.gz
		 https://github.com/paralect/robomongo-shell/archive/${ROBOSHELL_COMMIT}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">dev-qt/qtcore-5
		>dev-qt/qtgui-5[gtkstyle]
		>dev-qt/qtdbus-5
		>dev-qt/qtprintsupport-5
		>dev-qt/qtimageformats-5"

RDEPEND="${DEPEND}"

S=${WORKDIR}"/"${PN}"-"${MY_PV}
MONGODB_DIR=${WORKDIR}"/robomongo-shell-"${ROBOSHELL_COMMIT}
CMAKE_IN_SOURCE_BUILD=true

src_prepare() {
	cd ${MONGODB_DIR}
	epatch "${FILESDIR}/build_fix.patch"
	scons mongo --release --disable-warnings-as-errors CC="$(tc-getCC)" CXX="$(tc-getCXX)" ${MAKEOPTS}
	cd ${S}
	epatch "${FILESDIR}/build_fix_robomongo.patch"
}

src_configure() {
	mycmakeargs=(
		-DMongoDB_DIR:PATH=${MONGODB_DIR}
	)
	cmake-utils_src_configure
}

src_install() {
	cd ${BUILD_DIR}
	dobin src/robomongo/robomongo
	newicon install/macosx/Robomongo.iconset/icon_256x256.png robomongo.png
	make_desktop_entry robomongo Robomongo robomongo
	dodoc CHANGELOG COPYRIGHT LICENSE README.md
}