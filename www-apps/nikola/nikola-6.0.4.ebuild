# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/nikola/nikola-5.2.ebuild,v 1.2 2013/06/09 19:03:24 floppym Exp $


EAPI=5
PYTHON_COMPAT=( python{2_7,3_3} )
inherit distutils-r1

DESCRIPTION="A static website and blog generator"
HOMEPAGE="http://nikola.ralsina.com.ar/"
MY_PN="Nikola"

if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/ralsina/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="MIT-with-advertising"
SLOT="0"
IUSE="jinja markdown assets charts"

DEPEND="dev-python/docutils" # needs rst2man to build manpage
RDEPEND="${DEPEND}
	python_targets_python2_7? ( =dev-python/configparser-3.2.0* )
	>=dev-python/doit-0.20.0
	virtual/python-imaging
	dev-python/lxml
	>=dev-python/mako-0.6
	dev-python/pygments
	dev-python/PyRSS2Gen
	>=dev-python/requests-1.0
	dev-python/unidecode
	>=dev-python/yapsy-1.10.2
	dev-python/logbook
	>=dev-python/pytz-2013d
	dev-python/python-dateutil
	assets? ( dev-python/assets )
	charts? ( dev-python/pygal )
	jinja? ( >=dev-python/jinja-2.7 )
	markdown? ( dev-python/markdown )"

src_install() {
	distutils-r1_src_install

	# hackish way to remove docs that ended up in the wrong place
	rm -rf "${D}"/usr/share/doc/${PN}

	dodoc AUTHORS.txt CHANGES.txt README.rst docs/*.txt
	doman docs/man/*
}

pkg_postinst() {
	if has_version '<www-apps/nikola-5.0'; then
		elog 'Nikola has changed quite a lot since the previous major version.'
		elog 'Please make sure to read the updated documentation.'
	fi
}
