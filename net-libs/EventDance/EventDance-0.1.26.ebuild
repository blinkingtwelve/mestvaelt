# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools

DESCRIPTION="Peer-to-peer inter-process communication library."
HOMEPAGE="https://github.com/elima/EventDance"
SRC_URI="https://github.com/elima/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-libs/glib-2.28.0 \
		>=net-libs/libsoup-2.28.0 \
		>=net-libs/gnutls-2.12.0 \
		>=sys-apps/util-linux-2.16.0 \
		>=dev-libs/json-glib-0.14.0"
RDEPEND="${DEPEND}"


src_prepare() {
	./autogen.sh || die "autogen failed"
}

src_configure() {
	econf --enable-tests=no --enable-introspection=no || die "econf failed"
}