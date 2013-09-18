# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools

DESCRIPTION="Low friction, one click anonymous filesharing over HTTP(S)."
HOMEPAGE="https://github.com/elima/FileTea"
SRC_URI="https://github.com/elima/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=net-libs/EventDance-0.1.26 \
		>=dev-libs/json-glib-0.14.0"
RDEPEND="${DEPEND}"


src_prepare() {
	./autogen.sh || die "autogen failed"
}

src_configure() {
	econf --enable-tests=no || die "econf failed"
}

src_install() {
	doman filetea.8
	einstall
}
