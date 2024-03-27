# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

POSTGRES_COMPAT=( 15 16)

inherit desktop postgres qmake-utils

MY_PV=${PV/_/-}

DESCRIPTION="PostgreSQL Database Modeler"
HOMEPAGE="https://pgmodeler.io"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="${POSTGRES_DEP}
	dev-libs/icu:=
	dev-libs/libxml2:=
	dev-qt/qtbase:6
	dev-qt/qtsvg:6
"
RDEPEND="${DEPEND}"

DOCS=( CHANGELOG.md README.md RELEASENOTES.md )

S="${WORKDIR}/${PN}-${MY_PV}"

src_configure() {
	eqmake6 \
		PREFIX="${EPREFIX}/usr" \
		PLUGINSDIR="${EPREFIX}/usr/$(get_libdir)/${PN}/plugins" \
		PRIVATEBINDIR="${EPREFIX}/usr/$(get_libdir)/${PN}/bin" \
		PRIVATELIBDIR="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		NO_UPDATE_CHECK=1 \
		-r ${PN}.pro
}

src_test() {
	cd "${S}/tests" || die
	eqmake6 tests.pro
	emake
	emake check
}

src_install() {
	emake INSTALL_ROOT="${D}" install

	rm "${D}"/usr/share/${PN}/{CHANGELOG.md,LICENSE,README.md,RELEASENOTES.md}

	einstalldocs

	doicon assets/conf/${PN}_logo.png
	make_desktop_entry ${PN} ${PN} ${PN}_logo Development
}
