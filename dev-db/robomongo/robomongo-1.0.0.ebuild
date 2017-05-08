# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils toolchain-funcs

DESCRIPTION="Robomongo — is a shell-centric crossplatform MongoDB management tool."

ROBOSHELL_COMMIT="9fa2d97e189eac23451f7e565fc46bda86bca690"

HOMEPAGE="http://www.robomongo.org/"
SRC_URI="https://github.com/Studio3T/robomongo/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/paralect/robomongo-shell/archive/${ROBOSHELL_COMMIT}.zip -> roboshell-3.2.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">dev-qt/qtcore-5
		>dev-qt/qtgui-5[gtk]
		>dev-qt/qtdbus-5
		>dev-qt/qtprintsupport-5
		>dev-qt/qtimageformats-5
		dev-libs/openssl:0
"

RDEPEND="${DEPEND}"

MONGODB_DIR=${WORKDIR}"/robomongo-shell-"${ROBOSHELL_COMMIT}
CMAKE_IN_SOURCE_BUILD=true

src_prepare() {
	epatch "${FILESDIR}/build_fix_robomongo.patch"
	sed -i -e's/5.7.0\/QtGui/5.7.1\/QtGui/' src/robomongo/core/settings/SettingsManager.cpp
	cd ${MONGODB_DIR}
	epatch "${FILESDIR}/roboshell-fix.patch"
	scons mongo --release --ssl -j9 CXXFLAGS='-w' CFLAGS='-w' || die
	cd ${S}
}

src_configure() {
	rm -rf cmake/FindOpenSSL.cmake
	local mycmakeargs=(
		-DMongoDB_DIR="${MONGODB_DIR}"
	)
	cmake-utils_src_configure
}

src_install() {
	dobin src/robomongo/robomongo
	newicon install/macosx/robomongo.iconset/icon_256x256.png robomongo.png
	make_desktop_entry robomongo Robomongo robomongo
	dodoc CHANGELOG COPYRIGHT LICENSE README.md
}
