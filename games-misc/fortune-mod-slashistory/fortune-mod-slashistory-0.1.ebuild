# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="The history of the world according to Slashdot readers"
HOMEPAGE="http://smorgasbord.gavagai.nl/"
SRC_URI="http://smormedia.gavagai.nl/dist/fortunes/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

RDEPEND="games-misc/fortune-mod"

src_install() {
	insinto /usr/share/fortune
	doins slashistory slashistory.dat || die
}
