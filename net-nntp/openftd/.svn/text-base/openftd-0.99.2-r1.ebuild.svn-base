# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2 multilib autotools

DESCRIPTION="A dutch binary newsgroup post announce program."
HOMEPAGE="http://www.ftd4linux.nl"
SRC_URI="http://www.ftd4linux.nl/releases/openftd-${PV}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="firefox gtkhtml dbus spell"

DEPEND=">=sys-libs/zlib-1.1.4
		>=sys-libs/glibc-2.2.0
		>=x11-libs/gtk+-2.6.0
		>=dev-libs/libxml2-2.2.5
		>=dev-libs/libxslt-1.0.5
		>=net-misc/curl-7.10.6
		>=dev-libs/libpcre-5.0
		>=x11-libs/libnotify-0.4.1
		>=dev-db/sqlite-3.0.0
		spell? ( x11-libs/libsexy >=app-text/gtkspell-2.0 )
		gnome-base/libgnome
		gnome-base/libgnomeui
		dbus? ( sys-apps/dbus )
		firefox? ( dev-libs/nspr www-client/mozilla-firefox )
		gtkhtml? ( >=gnome-extra/gtkhtml-3.7 )
		!firefox? ( !gtkhtml? ( www-client/seamonkey ) )"

src_compile() {
	addpredict /usr/$(get_libdir)/seamonkey/components/xpti.dat
	addpredict /usr/$(get_libdir)/seamonkey/components/xpti.dat.tmp

	addpredict /usr/$(get_libdir)/mozilla-firefox/components/xpti.dat
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/xpti.dat.tmp
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/compreg.dat.tmp

	addpredict /usr/$(get_libdir)/xulrunner/components/xpti.dat
	addpredict /usr/$(get_libdir)/xulrunner/components/xpti.dat.tmp
	addpredict /usr/$(get_libdir)/xulrunner/components/compreg.dat.tmp

	addpredict /usr/$(get_libdir)/mozilla/components/xpti.dat
	addpredict /usr/$(get_libdir)/mozilla/components/xpti.dat.tmp

	epatch ${FILESDIR}/openftd-0.99.2.myftd.debug.patch
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make install DESTDIR=${D} || die

	dodoc README TODO COPYING NEWS TODO ChangeLog

	GENERIC_PLUGIN_TEST=`grep 'INSTALL_GENERIC_PLUGIN_TRUE = #' ${S}/Makefile`
}

pkg_postinst() {
	if [ "$GENERIC_PLUGIN_TEST" ]; then
		ewarn
		ewarn "No suitable auth plugin found for your system."
		ewarn "Please notify the developers at $HOMEPAGE"
		ewarn
	fi
}
