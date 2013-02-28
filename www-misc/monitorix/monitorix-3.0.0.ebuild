# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
SLOT="0"

inherit user

DESCRIPTION="A lighweight system monitoring tool"
HOMEPAGE="http://www.monitorix.org/"
SRC_URI="http://www.monitorix.org/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="smart hddtemp lm_sensors"

RDEPEND="net-analyzer/rrdtool[perl]
	dev-perl/libwww-perl
	dev-perl/MailTools
	virtual/perl-CGI
	dev-perl/MIME-Lite
	dev-perl/DBI
	dev-perl/XML-Simple
	dev-perl/config-general
	dev-perl/HTTP-Server-Simple
	smart? ( sys-apps/smartmontools )
	hddtemp? ( app-admin/hddtemp )
	lm_sensors? ( sys-apps/lm_sensors )"

pkg_setup() {
	enewgroup monitorix
	enewuser monitorix -1 -1 -1 "monitorix"
	}


src_install() {

	WEBDIR="/usr/share/${PN}"
	DATADIR="/var/lib/${PN}"

	dobin ${PN} || die "dobin failed"

	insinto /etc
	doins ${PN}.conf || die "doins failed"

	dodoc Changes docs/${PN}-apache.conf README{,.nginx} \
		docs/${PN}-alert.sh || die "dodoc failed"
	doman man/man5/${PN}.conf.5 || die "doman failed"
	doman man/man8/${PN}.8 || die "doman failed"

	insinto "${WEBDIR}"
	doins logo_bot.png logo_top.png monitorixico.png || die "doins failed"
	dodir "${WEBDIR}/imgs" || die "dodir failed"
	fowners monitorix:monitorix "${WEBDIR}/imgs" || die "fowners failed"
	dodir "${WEBDIR}/cgi" || die "dodir failed"

	exeinto "${WEBDIR}/cgi"
	doexe ${PN}.cgi || die "doexe failed"

	insinto /usr/lib/${PN} 
	doins -r lib/*pm || die "doins failed"

	dodir ${DATADIR}/usage || die "dodir failed"
	insinto ${DATADIR}/reports
	doins -r reports/* || die "doins failed"

	newinitd "${FILESDIR}"/${PN}.initd ${PN} || die "newinitd failed"
}

pkg_postinst() {
	elog "Before starting the ${PN} init script make sure you edited the "
	elog "config file. After that you can start ${PN} by running"
	elog "\t/etc/init.d/${PN} start"
	elog "If you want to start it automatically on boot run"
	elog "\trc-update add ${PN} default"
	elog
}
