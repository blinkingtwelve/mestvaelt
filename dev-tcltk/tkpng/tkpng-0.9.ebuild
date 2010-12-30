# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Implements support for loading and using PNG images with Tcl/Tk"
HOMEPAGE="http://sourceforge.net/projects/tkpng"
SRC_URI="http://prdownloads.sourceforge.net/tkpng/${PN}${PV}.tgz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~alpha amd64 ~ia64 ~ppc ~sparc x86"

IUSE=""
DEPEND="
	>=sys-libs/zlib-1.2.3-r1
	>=dev-lang/tcl-8.4.9
	>=dev-lang/tk-8.4.9
"

S="${WORKDIR}/${PN}${PV}"

src_unpack() {
	unpack ${A}
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}

