# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="W3C ical2html, icalfilter and icalmerge"
HOMEPAGE="http://www.w3.org/Tools/Ical2html/"
SRC_URI="http://www.w3.org/Tools/Ical2html/${P}.tar.gz"
LICENSE="W3C"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPEND=">=dev-libs/libical-0.44"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README
}
