# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/crda/crda-1.1.3.ebuild,v 1.3 2013/01/28 07:35:43 ssuominen Exp $

EAPI=4
inherit eutils toolchain-funcs python udev

DESCRIPTION="Central Regulatory Domain Agent for wireless networks."
HOMEPAGE="http://wireless.kernel.org/en/developers/Regulatory"
SRC_URI="http://linuxwireless.org/download/crda/${P}.tar.bz2"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND="dev-libs/libnl:3"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-missing-include.patch
	epatch "${FILESDIR}"/make_crypto_use_optional.patch
	sed -i \
		-e "s:\<pkg-config\>:$(tc-getPKG_CONFIG):" \
		Makefile || die
}

src_compile() {
	emake \
		UDEV_RULE_DIR="$(udev_get_udevdir)/rules.d" \
		REG_BIN=/usr/$(get_libdir)/crda/regulatory.bin \
		CC="$(tc-getCC)" \
		all_noverify V=1
}

src_test() {
	emake CC="$(tc-getCC)" verify
}

src_install() {
	emake \
		UDEV_RULE_DIR="$(udev_get_udevdir)/rules.d" \
		REG_BIN=/usr/$(get_libdir)/crda/regulatory.bin \
		DESTDIR="${D}" \
		install
}
