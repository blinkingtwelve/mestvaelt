# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils

DESCRIPTION="Lua bindings to zlib"
HOMEPAGE="http://github.com/brimworks/lua-zlib"
SRC_URI="https://github.com/brimworks/${PN}/tarball/v${PV} -> ${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="dev-lang/lua
		sys-libs/zlib"
DEPEND="${RDEPEND}
		dev-util/pkgconfig"


src_unpack() {
	unpack ${A}
	mv *-${PN}-* "${S}"
}

src_configure() {
	MYCMAKEARGS="-DINSTALL_CMOD='$(pkg-config --variable INSTALL_CMOD lua)'"
	cmake-utils_src_configure
}
