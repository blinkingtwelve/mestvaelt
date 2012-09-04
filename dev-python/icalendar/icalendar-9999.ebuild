# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/icalendar/icalendar-2.2.ebuild,v 1.5 2012/03/09 10:32:19 phajdan.jr Exp $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2"

inherit distutils git-2

MY_PN="collective-${PN}"
#S="${WORKDIR}/${MY_PN}-2354d4f"
#S="${WORKDIR}/${MY_PN}-2354d4f"

#https://nodeload.github.com/collective/icalendar/zipball/master

DESCRIPTION="Package used for parsing and generating iCalendar files (RFC 2445)."
HOMEPAGE="http://github.com/collective/icalendar"
#SRC_URI="http://github.com/collective/${PN}/tarball/${PV} -> ${P}.tar.gz"
#S="${WORKDIR}/${MY_PN}-2354d4f"
EGIT_REPO_URI="https://github.com/collective/icalendar.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86 ~x86-fbsd"
IUSE="doc"
RESTRICT="test"

RDEPEND=""
DEPEND="dev-python/setuptools
	dev-python/pytz 
	doc? ( dev-python/sphinx )"

RESTRICT_PYTHON_ABIS="3.*"

#DOCS="CHANGES.txt CREDITS.txt HISTORY.txt TODO.txt"

#src_compile() {
#	distutils_src_compile
#
#	if use doc; then
#		cd docs
#		emake text || die "building documentation"
#		DOCS="${DOCS} docs/_build/text/*.txt"
#	fi
#}
