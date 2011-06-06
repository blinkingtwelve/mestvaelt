# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI=2

inherit eutils autotools multilib flag-o-matic

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

DESCRIPTION="A statistical-algorithmic hybrid anti-spam filter"
HOMEPAGE="http://dspam.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-3.9.1-RC1.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~ppc sparc x86"
IUSE="clamav daemon external-lookup hash ldap mysql postgres sqlite syslog \
	large-domain virtual-users user-homedirs \
	debug debug-bnr debug-verbose static"

DEPEND="ldap?		( >=net-nds/openldap-2.2 )
	mysql?		( virtual/mysql )
	sqlite?		( =dev-db/sqlite-3* )
	postgres?	( >=dev-db/postgresql-base-8 )"
RDEPEND="${DEPEND}
	clamav?		( >=app-antivirus/clamav-0.90.2 )
	postgres?	( dev-python/psycopg )
	sys-process/cronbase
	virtual/logger"

# some FHS-like structure
DSPAM_HOMEDIR="/var/spool/dspam"
DSPAM_CONFDIR="/etc/mail/dspam"
DSPAM_LOGDIR="/var/log/dspam"
DSPAM_MODE=2511

pkg_setup() {
	# create dspam user and group
	create_dspam_user
}

S="${WORKDIR}/${PN}-3.9.1-RC1"

src_unpack() {
        unpack ${A}
        cd "${S}"
        epatch "${FILESDIR}"/${P}-lmtp-client-unsolicited-SIZE.patch
}


src_prepare() {
	AT_M4DIR="${S}/m4"
	eautoreconf
}

src_configure() {
	local myconf=""
	local STORAGE_DRIVERS
	local STORAGE_COUNTER=0

	# select storage driver
	if use hash; then
		STORAGE_DRIVERS="${STORAGE_DRIVERS},hash_drv"
		let STORAGE_COUNTER++
	fi
	if use sqlite; then
		STORAGE_DRIVERS="${STORAGE_DRIVERS},sqlite3_drv"
		let STORAGE_COUNTER++
	fi
	if use mysql; then
		STORAGE_DRIVERS="${STORAGE_DRIVERS},mysql_drv"
		myconf="${myconf} --with-mysql-includes=/usr/include/mysql"
		myconf="${myconf} --with-mysql-libraries=/usr/$(get_libdir)/mysql"
		let STORAGE_COUNTER++
	fi
	if use postgres; then
		STORAGE_DRIVERS="${STORAGE_DRIVERS},pgsql_drv"
		myconf="${myconf} --with-pgsql-includes=/usr/include/postgresql"
		myconf="${myconf} --with-pgsql-libraries=/usr/$(get_libdir)"
		let STORAGE_COUNTER++
	fi
	if [ -z "${STORAGE_DRIVERS}" -o ${STORAGE_COUNTER} -eq 0 ]; then
		eerror
		eerror "You have not selected any DSPAM storage driver. Please enable one of the"
		eerror "following USE flags: hash, mysql, postgres or sqlite"
		eerror
		die "No storage driver selected"
	fi
	if [ "${STORAGE_DRIVERS:0:1}" = "," ]; then
		STORAGE_DRIVERS="${STORAGE_DRIVERS:1}"
	fi
	if [ "${STORAGE_COUNTER}" -gt 1 ]; then
		if use static; then
			eerror
			eerror "You use \"static\" USE flag but have selected multiple storage backends."
			eerror "DSPAM can only be build with one statically linked storage driver. Please"
			eerror "change your USE flags and select one of:"
			eerror "  hash, mysql, postgres or sqlite"
			eerror
			eerror "Or disable the \"static\" USE flag."
			eerror
			die "Multiple storage driver selected and 'static' USE flag enabled"
		fi
	elif [ "${STORAGE_COUNTER}" -eq 1 ] && (! use static); then
		# Build just one storage driver but NOT statically linked
		STORAGE_DRIVERS="${STORAGE_DRIVERS},${STORAGE_DRIVERS}"
		let STORAGE_COUNTER++
	fi

	if use mysql || use postgres; then
		myconf="${myconf} $(use_enable virtual-users) --enable-preferences-extension"
		if use virtual-users; then
			myconf="${myconf} --disable-homedir"
			use user-homedirs && ewarn "user-homedirs support has been disabled (not compatible with --enable-virtual-users)"
		else
			myconf="${myconf} $(use_enable user-homedirs homedir)"
		fi
	else
		myconf="${myconf} --disable-virtual-users --disable-preferences-extension \
			 $(use_enable user-homedirs homedir)"
		use virtual-users && ewarn "virtual-users support has been disabled (available only for mysql and postgres storage drivers)"
	fi

	if ! use syslog; then
		myconf="${myconf} --with-logfile=${DSPAM_LOGDIR}/dspam.log"
	fi

	if use debug; then
		append-flags -g2 -ggdb
		filter-flags -fomit-frame-pointer
	fi

	export CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)"

	econf --with-storage-driver=${STORAGE_DRIVERS} \
		--with-dspam-home="${DSPAM_HOMEDIR}" \
		--sysconfdir="${DSPAM_CONFDIR}" \
		$(use_enable daemon) \
		$(use_enable external-lookup) \
		$(use_enable clamav) \
		$(use_enable large-domain large-scale) \
		$(use_enable !large-domain domain-scale) \
		$(use_enable syslog) \
		$(use_enable debug) \
		$(use_enable debug-bnr bnr-debug) \
		$(use_enable debug-verbose verbose-debug) \
		--enable-long-usernames \
		--with-dspam-group=dspam \
		--with-dspam-home-group=dspam \
		--with-dspam-mode=${DSPAM_MODE} \
		--with-logdir="${DSPAM_LOGDIR}" \
		${myconf} || die "econf failed"
}

src_compile() {
	export CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)"
	emake || die "emake failed"
}

src_install () {
	diropts -m0770 -o dspam -g dspam
	dodir "${DSPAM_CONFDIR}"
	insinto "${DSPAM_CONFDIR}"
	insopts -m640 -o dspam -g dspam
	doins src/dspam.conf
	dosym /etc/mail/dspam /etc/dspam

	# make install
	emake DESTDIR="${D}" install || die "emake install failed"

	# necessary for dovecot-dspam
	insopts -m644
	insinto /usr/include/dspam && doins src/pref.h

	# necessary for libdspam
	insopts -m644
	insinto /usr/include/dspam && doins src/auto-config.h

	diropts -m0755 -o dspam -g dspam
	dodir /var/run/dspam

	# create logdir (used only when syslog support has been disabled or build with --enable-debug)
	if ! use syslog || use debug; then
		diropts -m0770 -o dspam -g dspam
		dodir "${DSPAM_LOGDIR}"
		diropts -m0755
		insinto /etc/logrotate.d
		newins "${FILESDIR}/logrotate.dspam" dspam || die "failed to install logrotate.d file"
	fi

	if use daemon; then
		# we use sockets for the daemon instead of tcp port 24
		sed -e 's:^#*\(ServerDomainSocketPath[\t ]\{1,\}\).*:\1\"/var/run/dspam/dspam.sock\":gI' \
			-e 's:^#*\(ServerPID[\t ]\{1,\}\).*:\1/var/run/dspam/dspam.pid:gI' \
			-e 's:^#*\(ClientHost[\t ]\{1,\}\)/.*:\1\"/var/run/dspam/dspam.sock\":gI' \
			-i "${D}/${DSPAM_CONFDIR}/dspam.conf"

		newinitd "${FILESDIR}/dspam.initd" dspam || die "failed to install init script"
		newconfd "${FILESDIR}/dspam.confd" dspam || die "failed to install init config"
		fowners root:dspam /usr/bin/dspamc &&
			fperms u=rx,g=xs,o=x /usr/bin/dspamc ||
			die "failed to alter dspamc owner:group or mode"
	fi

	# database related configuration and scripts
	local PASSWORD="${RANDOM}${RANDOM}${RANDOM}${RANDOM}" DSPAM_DB_DATA=()
	if use sqlite; then
		insinto "${DSPAM_CONFDIR}"
		newins src/tools.sqlite_drv/purge-3.sql sqlite3_purge.sql || die "failed to install sqlite3_purge.sql script"
	fi
	if use mysql; then
		DSPAM_DB_DATA[0]="/var/run/mysqld/mysqld.sock"
		DSPAM_DB_DATA[1]=""
		DSPAM_DB_DATA[2]="dspam"
		DSPAM_DB_DATA[3]="${PASSWORD}"
		DSPAM_DB_DATA[4]="dspam"
		DSPAM_DB_DATA[5]="false"

		# activate MySQL database configuration
		sed -e "s:^#*\(MySQLServer[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[0]}:gI" \
			-e "s:^#*\(MySQLPort[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[1]}:gI" \
			-e "s:^#*\(MySQLUser[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[2]}:gI" \
			-e "s:^#*\(MySQLPass[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[3]}:gI" \
			-e "s:^#*\(MySQLDb[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[4]}:gI" \
			-e "s:^#*\(MySQLCompress[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[5]}:gI" \
			-i "${D}/${DSPAM_CONFDIR}/dspam.conf"

		insinto "${DSPAM_CONFDIR}"
		newins src/tools.mysql_drv/mysql_objects-space.sql mysql_objects-space.sql &&
			newins src/tools.mysql_drv/mysql_objects-speed.sql mysql_objects-speed.sql &&
			newins src/tools.mysql_drv/mysql_objects-4.1.sql mysql_objects-4.1.sql &&
			newins src/tools.mysql_drv/purge.sql mysql_purge.sql &&
			newins src/tools.mysql_drv/purge-4.1.sql mysql_purge-4.1.sql ||
			die "failed to install mysql*.sql scripts"
		if use virtual-users; then
			newins src/tools.mysql_drv/virtual_users.sql mysql_virtual_users.sql &&
				newins src/tools.mysql_drv/virtual_user_aliases.sql mysql_virtual_user_aliases.sql ||
				die "failed to install mysql_virtual_user*.sql scripts"
		fi
	fi
	if use postgres; then
		DSPAM_DB_DATA[0]="/var/run/postgresql/"
		DSPAM_DB_DATA[1]=""
		DSPAM_DB_DATA[2]="dspam"
		DSPAM_DB_DATA[3]="${PASSWORD}"
		DSPAM_DB_DATA[4]="dspam"

		# activate PostgreSQL database configuration
		sed -e "s:^#*\(PgSQLServer[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[0]}:gI" \
			-e "s:^#*\(PgSQLPort[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[1]}:gI" \
			-e "s:^#*\(PgSQLUser[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[2]}:gI" \
			-e "s:^#*\(PgSQLPass[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[3]}:gI" \
			-e "s:^#*\(PgSQLDb[\t ]\{1,\}\).*:\1${DSPAM_DB_DATA[4]}:gI" \
			-e "s:^#*\(PgSQLConnectionCache[\t ]*.\):\1:gI" \
			-i "${D}/${DSPAM_CONFDIR}"/dspam.conf

		insinto "${DSPAM_CONFDIR}"
		newins src/tools.pgsql_drv/pgsql_objects.sql pgsql_objects.sql &&
			newins src/tools.pgsql_drv/purge-pe.sql pgsql_pe-purge.sql &&
			newins src/tools.pgsql_drv/purge.sql pgsql_purge.sql ||
			die "failed to install pgsql*.sql scripts"
		if use virtual-users; then
			newins src/tools.pgsql_drv/virtual_users.sql pgsql_virtual_users.sql ||
				die "failed to install pgsql_virtual_users.sql scripts"
		fi

		# install psycopg scripts needed when PostgreSQL is not installed
		exeinto "${DSPAM_CONFDIR}"
		doexe "${FILESDIR}"/pgsql_{createdb,purge}.py || die "failed to install psycopg scripts"
	fi

	# set default storage
	if use static; then
		set_storage_driver none "${D}/${DSPAM_CONFDIR}/dspam.conf"
	elif use hash; then
		set_storage_driver hash "${D}/${DSPAM_CONFDIR}/dspam.conf"
	elif use postgres; then
		set_storage_driver pgsql "${D}/${DSPAM_CONFDIR}/dspam.conf"
	elif use mysql; then
		set_storage_driver mysql "${D}/${DSPAM_CONFDIR}/dspam.conf"
	else
		set_storage_driver sqlite3 "${D}/${DSPAM_CONFDIR}/dspam.conf"
	fi

	if use hash; then
		# see bug #185718
		sed -e "s:^Tokenizer[\t ]*.*$:Tokenizer sbph:" \
			-e "s:^PValue[\t ]*.*$:PValue markov:" \
			-i "${D}/${DSPAM_CONFDIR}"/dspam.conf
	else
		# use purge configuration for SQL-based installations
		sed -e "s:^\(Purge.*\):###\1:g" \
			-e "s:^#\(Purge.*\):\1:g" \
			-e "s:^###\(Purge.*\):#\1:g" \
			-i "${D}/${DSPAM_CONFDIR}"/dspam.conf
	fi

	# create the opt-in / opt-out directories
	diropts -m0770 -o dspam -g dspam
	dodir "${DSPAM_HOMEDIR}"
	keepdir "${DSPAM_HOMEDIR}"/opt-in
	keepdir "${DSPAM_HOMEDIR}"/opt-out
	keepdir "${DSPAM_HOMEDIR}"/txt
	diropts -m0755

	# install the notification messages
	local msgtags=("Scanned and tagged as" "with DSPAM ${PV} running on Gentoo Linux by Your ISP.com")
	echo "${msgtags[0]} SPAM ${msgtags[1]}" >"${T}"/msgtag.spam
	echo "${msgtags[0]} non-SPAM ${msgtags[1]}" >"${T}"/msgtag.nonspam
	insinto "${DSPAM_HOMEDIR}"/txt
	doins "${S}"/txt/*.txt
	doins "${T}"/msgtag.*

	# maintenance script
	exeinto /usr/bin
	newexe "${S}"/contrib/dspam_maintenance/dspam_maintenance.sh dspam_maintenance || die "newexe failed"

	# DSPAM cron job
	echo -e '#!/bin/sh\n\n# See "dspam_maintenance --help" for\n# a list of additional parameters.\n\n/usr/bin/dspam_maintenance > /dev/null' > "${T}"/dspam.cron
	exeinto /etc/cron.daily
	newexe "${T}"/dspam.cron dspam || die "failed to install cron script"

	# documentation
	dodoc CHANGELOG README* RELEASE.NOTES UPGRADING
	docinto doc
	dodoc doc/*.txt
	docinto gentoo
	dodoc "${FILESDIR}"/README.{postfix,qmail}
	doman man/dspam*
}

pkg_postinst() {
	if use hash; then
		ewarn
		ewarn "The hash_drv storage backend has the following requirements:"
		ewarn "  - PValue must be set to 'markov'; Do not use this PValue with any other storage backend!"
		ewarn "  - Tokenizer must be either 'sbph' or 'osb'"
		ewarn "See markov.txt for more info."
	fi
	if use mysql || use postgres; then
		elog
		elog "To setup DSPAM to run out-of-the-box on your system with a MySQL"
		elog "or PostgreSQL database, run:"
		elog "emerge --config =${PF}"
	fi
	if use daemon; then
		elog
		elog "If you want to run DSPAM in the new daemon mode remember to make"
		elog "the DSPAM daemon start during boot:"
		elog "  rc-update add dspam default"
		elog
		elog "To use the DSPAM daemon mode, the used storage driver must be thread-safe."
	fi
	elog
	elog "Visit http://apps.sf.net/mediawiki/dspam/ for more info"
}

create_dspam_user() {
	local egid euid
	# Need a UID and GID >= 1000, for being able to use suexec in apache
	for euid in $(seq 1000 5000 ) ; do
		[ -z "$(egetent passwd ${euid})" ] && break
	done
	for egid in $(seq 1000 5000 ) ; do
		[ -z "$(egetent group ${egid})" ] && break
	done
	enewgroup dspam ${egid}
	enewuser dspam ${euid} -1 "${DSPAM_HOMEDIR}" dspam,mail
}

# Edits interactively one or more parameters from "${ROOT}${DSPAM_CONFDIR}/dspam.conf"
# Usage: edit_dspam_params param_name1 [param_name2 ..]
edit_dspam_params() {
	local PARAMETER OLD_VALUE VALUE
	for PARAMETER in $@ ; do
		OLD_VALUE=$(awk "BEGIN { IGNORECASE=1; } \$1==\"${PARAMETER}\" { print \$2; exit; }" "${ROOT}${DSPAM_CONFDIR}/dspam.conf")
		[ $? = 0 ] || return 1
		if [ "${PARAMETER}" = *"Pass" ]; then
			read -r -p "${PARAMETER} (default ${OLD_VALUE:-none}; enter random for generating a new random password): " VALUE
			[ "${VALUE}" = "random" ] && VALUE="${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
		else
			read -r -p "${PARAMETER} (default ${OLD_VALUE:-none}): " VALUE
		fi

		if [ -z "${VALUE}" ]; then
			VALUE=${OLD_VALUE}
		else
			sed -e "s:^#*${PARAMETER}\([\t ].*\)\?\$:${PARAMETER} ${VALUE}:gI" \
				-i "${ROOT}${DSPAM_CONFDIR}/dspam.conf"
			[ ${?} = 0 ] || return 2
		fi
		eval $PARAMETER=\"${VALUE}\"
	done
	return 0
}

# Selects the storage driver in "${ROOT}${DSPAM_CONFDIR}/dspam.conf"
# or in any other dspam.conf (second parameter).
# Usage: set_storage_driver { none | hash | sqlite3 | mysql | pgsql }
set_storage_driver() {
	local myconf="${ROOT}${DSPAM_CONFDIR}"/dspam.conf
	if [ -n "${2}" -a -f "${2}" ]; then
		myconf="${2}"
	fi
	if [ "${1}" = "none" ]; then
		sed	-e "s:^\([\t ]*StorageDriver[\t ].*\)$:#\1:" \
			-i "${myconf}" &&
			einfo "Storage driver entry disabled in dspam.conf"
	else
		sed	-e "s:^[#\t ]*\(StorageDriver[\t ].*\)lib[a-z1-9]\+_drv.so:\1lib${1}_drv.so:" \
			-i "${myconf}" &&
			einfo "Storage driver lib${1}_drv.so has been selected"
	fi
}

pkg_config () {
	local AVAIL_BACKENDS=( )
	use hash && AVAIL_BACKENDS=( ${AVAIL_BACKENDS[*]} hash )
	use sqlite && AVAIL_BACKENDS=( ${AVAIL_BACKENDS[*]} sqlite )
	use mysql && AVAIL_BACKENDS=( ${AVAIL_BACKENDS[*]} mysql )
	use postgres && AVAIL_BACKENDS=( ${AVAIL_BACKENDS[*]} postgres )
	local USE_BACKEND
	einfo "  Please select what backend you like to use:"
	for back in $(seq 0 1 $((${#AVAIL_BACKENDS[@]} - 1))); do
		einfo "    [${back}] ${AVAIL_BACKENDS[${back}]}"
	done
	einfo
	while read -n 1 -s -p "  Which backend do you want to configure? " USE_BACKEND; do
		if [ "${USE_BACKEND}" -ge "0" -a "${USE_BACKEND}" -lt "${#AVAIL_BACKENDS[@]}" ]; then
			USE_BACKEND="${AVAIL_BACKENDS[${USE_BACKEND}]}"
			echo
			break
		fi
	done
	case "${USE_BACKEND}" in
		hash)
			einfo "Hash driver will automatically create the necessary databases"
			set_storage_driver hash
			;;

		sqlite)
			einfo "SQLite driver will automatically create the necessary databases"
			set_storage_driver sqlite3
			;;

		mysql)
			local MySQLServer MySQLPort MySQLUser MySQLPass MySQLDb MySQLCompress
			edit_dspam_params MySQLServer MySQLPort MySQLUser MySQLPass MySQLDb MySQLCompress || return $?
			if [ -z "${MySQLServer}" -o -z "${MySQLUser}" -o -z "${MySQLPass}" -o -z "${MySQLDb}" ]; then
				eerror "Following parameters are required: MySQLServer MySQLUser MySQLPass MySQLDb"
				return 1
			fi

			local MySQL_DB_Type MySQL_Virtuser_Type
			einfo "  Please select what kind of database you like to create:"
			einfo "    [0] Don't create the database, I will do it myself"
			einfo "    [1] Database will be hosted on a mysql-4.1 server or above"
			einfo "    [2] Space optimized database on a mysql-4.0 server or below"
			einfo "    [3] Speed optimized database on a mysql-4.0 server or below"
			einfo
			while read -n 1 -s -p "  Press 0, 1, 2 or 3 on the keyboard to select database " MySQL_DB_Type; do
				if [ "${MySQL_DB_Type}" = "0" ]; then
					echo
					set_storage_driver mysql
					return 0
				fi
				[ "${MySQL_DB_Type}" = "1" -o "${MySQL_DB_Type}" = "2" -o "${MySQL_DB_Type}" = "3" ] && echo && break
			done
			if use virtual-users; then
				einfo "  Please select what kind of virtual_uids table you like to use:"
				einfo "    [1] Virtual users added automatically (use it if this server is the primary MX)"
				einfo "    [2] Virtual users added manually (use it if this server is a secondary MX)"
				einfo
				while read -n 1 -s -p "  Press 1 or 2 on the keyboard to select table type " MySQL_Virtuser_Type; do
					[ "${MySQL_Virtuser_Type}" = "1" -o "${MySQL_Virtuser_Type}" = "2" ] && echo && break
				done
			fi

			local MYSQL_ROOT_USER
			read -r -p "Your administrative MySQL account (default root): " MYSQL_ROOT_USER
			if [ -z "${MYSQL_ROOT_USER}" ]; then
				MYSQL_ROOT_USER="root"
			fi
			einfo "When prompted for a password, please enter your MySQL ${MYSQL_ROOT_USER} password"

			local MYSQL_CMD_LINE="/usr/bin/mysql -u ${MYSQL_ROOT_USER} -p"
			[ "${MySQLServer:0:1}" != "/" ] && MYSQL_CMD_LINE="${MYSQL_CMD_LINE} -h ${MySQLServer}"
			[ -n "${MySQLPort}" ] && MYSQL_CMD_LINE="${MYSQL_CMD_LINE} -P ${MySQLPort}"
			{
				echo "CREATE DATABASE ${MySQLDb};"
				echo "USE ${MySQLDb};"
				case ${MySQL_DB_Type} in
					1) cat "${ROOT}${DSPAM_CONFDIR}"/mysql_objects-4.1.sql ;;
					2) cat "${ROOT}${DSPAM_CONFDIR}"/mysql_objects-space.sql ;;
					3) cat "${ROOT}${DSPAM_CONFDIR}"/mysql_objects-speed.sql ;;
				esac
				if use virtual-users; then
					case ${MySQL_Virtuser_Type} in
						1) cat "${ROOT}${DSPAM_CONFDIR}"/mysql_virtual_users.sql ;;
						2) cat "${ROOT}${DSPAM_CONFDIR}"/mysql_virtual_user_aliases.sql ;;
					esac
				fi
				echo "GRANT SELECT,INSERT,UPDATE,DELETE ON ${MySQLDb}.* TO '${MySQLUser}'@'%' IDENTIFIED BY '${MySQLPass}';"
				echo "GRANT SELECT,INSERT,UPDATE,DELETE ON ${MySQLDb}.* TO '${MySQLUser}'@'localhost' IDENTIFIED BY '${MySQLPass}';"
				echo "FLUSH PRIVILEGES;"
			} | ${MYSQL_CMD_LINE}
			[ ${PIPESTATUS[1]} = 0 ] || return ${PIPESTATUS[1]}

			einfo "MySQL database created successfully"
			set_storage_driver mysql
			;;

		postgres)
			local PgSQLServer PgSQLPort PgSQLUser PgSQLPass PgSQLDb
			edit_dspam_params PgSQLServer PgSQLPort PgSQLUser PgSQLPass PgSQLDb || return $?
			if [ -z "${PgSQLServer}" -o -z "${PgSQLUser}" -o -z "${PgSQLPass}" -o -z "${PgSQLDb}" ]; then
				eerror "Following parameters are required: PgSQLServer PgSQLUser PgSQLPass PgSQLDb"
				return 1
			fi

			local PgSQL_DB_Create
			einfo "  Do you want PostgreSQL database be automatically created for you?"
			while read -n 1 -s -p "  Press y or n " PgSQL_DB_Create; do
				if [ "${PgSQL_DB_Create}" = "n" -o "${PgSQL_DB_Create}" = "N" ]; then
					echo
					set_storage_driver pgsql
					return 0
				fi
				[ "${PgSQL_DB_Create}" = "y" -o "${PgSQL_DB_Create}" = "Y" ] && echo && break
			done

			local PGSQL_ROOT_USER
			read -r -p "Your administrative PostgreSQL account (default postgres): " PGSQL_ROOT_USER
			if [ -z "${PGSQL_ROOT_USER}" ]; then
				PGSQL_ROOT_USER="postgres"
			fi
			einfo "When prompted for a password, please enter your PostgreSQL ${PGSQL_ROOT_USER} password"

			if [ -x /usr/bin/psql ]; then
				# Create database using psql
				local PGSQL_CMD_LINE="/usr/bin/psql -h ${PgSQLServer}"
				[ -n "${PgSQLPort}" ] && PGSQL_CMD_LINE="${PGSQL_CMD_LINE} -p ${PgSQLPort}"
				{
					echo "\\set ON_ERROR_STOP = on;"
					echo "CREATE USER ${PgSQLUser} WITH PASSWORD '${PgSQLPass}' NOCREATEDB NOCREATEUSER;"
					echo "CREATE DATABASE ${PgSQLDb};"
					echo "GRANT ALL PRIVILEGES ON DATABASE ${PgSQLDb} TO ${PgSQLUser};"
					echo "GRANT ALL PRIVILEGES ON SCHEMA public TO ${PgSQLUser};"
					echo "UPDATE pg_database SET datdba=(SELECT usesysid FROM pg_shadow WHERE usename='${PgSQLUser}') WHERE datname='${PgSQLDb}';"
					echo "\\c ${PgSQLDb};"
					echo "CREATE FUNCTION plpgsql_call_handler() RETURNS language_handler AS '\$libdir/plpgsql', 'plpgsql_call_handler' LANGUAGE c;"
					echo "CREATE FUNCTION plpgsql_validator(oid) RETURNS void AS '\$libdir/plpgsql', 'plpgsql_validator' LANGUAGE c;"
					echo "CREATE TRUSTED PROCEDURAL LANGUAGE plpgsql HANDLER plpgsql_call_handler VALIDATOR plpgsql_validator;"
				} | ${PGSQL_CMD_LINE} -d template1 -U ${PGSQL_ROOT_USER}
				[ ${PIPESTATUS[1]} = 0 ] || return ${PIPESTATUS[1]}

				{
					echo "\\set ON_ERROR_STOP = on;"
					cat "${ROOT}${DSPAM_CONFDIR}"/pgsql_objects.sql
					use virtual-users && cat "${ROOT}${DSPAM_CONFDIR}"/pgsql_virtual_users.sql
				} | PGUSER="${PgSQLUser}" PGPASSWORD="${PgSQLPass}" ${PGSQL_CMD_LINE} -d "${PgSQLDb}" -U ${PgSQLUser}
				[ ${PIPESTATUS[1]} = 0 ] || return ${PIPESTATUS[1]}
			else
				# Create database using psycopg script
				if use virtual-users; then
					DSPAM_PgSQLPass="${PgSQLPass}" "${ROOT}${DSPAM_CONFDIR}"/pgsql_createdb.py "${PgSQLServer}" "${PgSQLPort}" "${PGSQL_ROOT_USER}" \
						"${PgSQLUser}" "${PgSQLDb}" "${ROOT}${DSPAM_CONFDIR}"/pgsql_objects.sql "${ROOT}${DSPAM_CONFDIR}"/pgsql_virtual_users.sql
				else
					DSPAM_PgSQLPass="${PgSQLPass}" "${ROOT}${DSPAM_CONFDIR}"/pgsql_createdb.py "${PgSQLServer}" "${PgSQLPort}" "${PGSQL_ROOT_USER}" \
						"${PgSQLUser}" "${PgSQLDb}" "${ROOT}${DSPAM_CONFDIR}"/pgsql_objects.sql
				fi
				[ ${?} = 0 ] || return $?
			fi

			einfo "PostgreSQL database created successfully"
			set_storage_driver pgsql
			;;
	esac
}
