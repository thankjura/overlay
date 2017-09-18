# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

DESCRIPTION="A 3D game engine by Epic Games which can be used non-commercially for free."
HOMEPAGE="https://github.com/EpicGames/UnrealEngine"
#SRC_URI="https://github.com/EpicGames/UnrealEngine/archive/${PV}-release.tar.gz -> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/EpicGames/UnrealEngine.git"
EGIT_BRANCH="master"
EGIT_COMMIT="163e3403a9de73d6fad9aca99f2fed49fc433b34"

LICENSE="UnrealEngine"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-lang/mono
	sys-devel/clang
	dev-util/cmake
	media-libs/libsdl2
	dev-libs/icu
"
RDEPEND="${DEPEND}"

CHECKREQS_DISK_BUILD="34G"

src_prepare() {
	eapply_user
	./Setup.sh || die
	./GenerateProjectFiles.sh || die
}

src_compile() {
	emake -j1
}

src_install() {
	dodir /opt/UnrealEngine/Engine/DerivedDataCache
	dodir /opt/UnrealEngine/Engine/Intermediate
	mv Engine/{Binaries,Build,Config,Content,Documentation,Extras,Plugins,Programs,Saved,Shaders,Source} ${D}opt/UnrealEngine/Engine
	mv FeaturePacks Samples Templates GenerateProjectFiles.sh Setup.sh .ue4dependencies ${D}opt/UnrealEngine
	
	fperms -R g+rwx /opt/UnrealEngine/Engine
	fperms 0755 /opt/UnrealEngine/GenerateProjectFiles.sh
	fperms 0755 /opt/UnrealEngine/Setup.sh
	fperms 0644 /opt/UnrealEngine/.ue4dependencies

	dosym /opt/UnrealEngine/Engine/Binaries/Linux/UE4Editor /usr/bin/UE4Editor

	newicon Engine/Source/Programs/UnrealVS/Resources/Preview.png UE4Editor.png
	dodoc LICENSE.md README.md
	make_desktop_entry UE4Editor UE4Editor UE4Editor "Development" "Path=/opt/UnrealEngine/Engine"
}

