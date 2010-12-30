# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

DESCRIPTION="Pdf viewer and presentation program, based on K**j****"
HOMEPAGE="http://smormedia.gavagai.nl/dist/accentuate/"
SRC_URI="http://smormedia.gavagai.nl/dist/accentuate/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="lirc"

DEPEND=">=dev-lang/python-2.3
	dev-python/pyopengl
	dev-python/pygame
	dev-python/imaging
	|| ( app-text/poppler virtual/ghostscript )
	app-text/pdftk
	lirc? ( dev-python/pylirc )
	!media-gfx/keyjnote"

src_install() {
	newbin "${WORKDIR}/${PN}/${PN}" ${PN} || die
}
