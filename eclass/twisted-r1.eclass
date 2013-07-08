# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2 or later
# $Header: /var/cvsroot/gentoo-x86/eclass/twisted.eclass,v 1.10 2011/12/27 06:54:23 floppym Exp $

# @ECLASS: twisted-r1.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
# @BLURB: Eclass for Twisted packages
# @DESCRIPTION:
# The twisted eclass defines phase functions for Twisted packages.

# @ECLASS-VARIABLE: MY_PACKAGE
# @DESCRIPTION:
# Package name suffix.
# Required for dev-python/twisted* packages, unused otherwise.
# Needs to be set before inherit.

# @ECLASS-VARIABLE: MY_PV
# @DESCRIPTION:
# Package version.
# For dev-python/twisted* packages optional otherwise defaults to ebuilds
# major.minor.
# For other packages unused.
# Needs to be set before inherit

inherit distutils-r1 versionator

EXPORT_FUNCTIONS src_install pkg_postinst pkg_postrm

if [[ "${CATEGORY}/${PN}" == "dev-python/twisted"* ]]; then
	MY_PV="${MY_PV:-${PV}}"
	MY_P="Twisted${MY_PACKAGE}-${MY_PV}"

	HOMEPAGE="http://www.twistedmatrix.com/"
	SRC_URI="http://twistedmatrix.com/Releases/${MY_PACKAGE}"
	SRC_URI="${SRC_URI}/$(get_version_component_range 1-2 ${MY_PV})"
	SRC_URI="${SRC_URI}/${MY_P}.tar.bz2"

	LICENSE="MIT"
	SLOT="0"
	IUSE=""

	S="${WORKDIR}/${MY_P}"

	[[ ${TWISTED_PLUGINS} ]] || TWISTED_PLUGINS=( twisted.plugins )
fi

# @ECLASS-VARIABLE: TWISTED_PLUGINS
# @DESCRIPTION:
# An array of Twisted plugins, whose cache is regenerated in pkg_postinst() and
# pkg_postrm() phases.


# @FUNCTION: twisted-r1_python_test
# @DESCRIPTION:
# python_test function for dev-python/twisted-* ebuilds
twisted-r1_python_test() {
	local sitedir="$(python_get_sitedir)"

	# Copy modules of other Twisted packages from site-packages
	# directory to temporary directory.
	local libdir=${BUILD_DIR}/test/lib
	mkdir -p ${libdir}
	cp -r "${ROOT}${sitedir}/twisted" ${libdir} || \
		die "Copying twisted modules failed with ${EPYTHON}"
	rm -fr "${libdir}/${PN/-//}"

	distutils_install_for_testing || \
		die "install for testing failed $EPYTHON"

	cd ${TEST_DIR}/lib || die "cd failed for $EPYTHON"
	trial ${PN/-/.} || die "tests failed for $EPYTHON"
}

twisted-r1_src_install() {
	[[ "${CATEGORY}/${PN}" == "dev-python/twisted"* ]] && \
	[[ -d doc ]] && \
		HTML_DOCS=( "doc/" )

	distutils-r1_src_install

	if [[ -d doc/man ]]; then
		doman doc/man/*.[[:digit:]]
	fi
}

_twisted-r1_foreach_plugin() {
	debug-print-function ${FUNCNAME} "${@}"

	local rc=0

	for module in ${TWISTED_PLUGINS[@]}; do
		${@} $module || rc=1
	done

	return $rc
}

_twisted-r1_delete_caches() {
	local module=$1

	[[ -z "${module}" ]] && \
		{ eerror "empty module for $EPYTHON"; return 1; }

	[[ -d "${ROOT}$(python_get_sitedir)/${module//.//}" ]] && \
		find "${ROOT}$(python_get_sitedir)/${module//.//}" \
			-name dropin.cache -delete
}

_twisted-r1_create_caches() {
	# http://twistedmatrix.com/documents/current/core/howto/plugin.html
	local module=$1

	[[ -z "${module}" ]] && \
		{ eerror "empty module for $EPYTHON"; return 1; }

	"${PYTHON}" -c \
"import sys
sys.path.insert(0, '${ROOT}$(python_get_sitedir)')

try:
	import twisted.plugin
	import ${module}
except ImportError:
	if '${EBUILD_PHASE}' == 'postinst':
		raise
	else:
		# Twisted, zope.interface or given plugins might have been
		# uninstalled.
		sys.exit(0)

list(twisted.plugin.getPlugins(twisted.plugin.IPlugin, ${module}))"
}

_twisted-r1_delete_empty_dirs() {
	# Delete empty parent directories.
	local module=$1
	local dir="${ROOT}$(python_get_sitedir)/${module//.//}"

	[[ -z "${module}" ]] && \
		{ eerror "empty module for $EPYTHON"; return 1; }

	while [[ "${dir}" != "${EROOT%/}" ]]; do
		rmdir "${dir}" 2> /dev/null || break
		dir="${dir%/*}"
	done
}

_twisted-r1_update_plugin_cache() {
	local rc=0

	_twisted-r1_foreach_plugin _twisted-r1_delete_caches
	_twisted-r1_foreach_plugin _twisted-r1_create_caches || rc=1
	_twisted-r1_foreach_plugin _twisted-r1_delete_empty_dirs

	return $rc
}

twisted-r1_pkg_postinst() {
	_distutils-r1_run_foreach_impl _twisted-r1_update_plugin_cache
}

twisted-r1_pkg_postrm() {
	_distutils-r1_run_foreach_impl _twisted-r1_update_plugin_cache
}
